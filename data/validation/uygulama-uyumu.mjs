import {spawnSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {read} from './sozlesme.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'../..');
export function inspectApplication(pinned=false){
  const registry=read('validation/kaynaklar.json');
  const sources=Object.fromEntries(registry.files.map(row=>{
    const raw=pinned?spawnSync('git',['show',`${row.commit}:${row.path}`],{cwd:root}).stdout:readFileSync(resolve(root,row.path));
    assert(raw?.length,'missing-source:'+row.path);
    if(pinned)assert.equal(createHash('sha256').update(raw).digest('hex'),row.sha256,'source-drift:'+row.path);
    return [row.path,raw.toString('utf8')];
  }));
  const projects=sources['lib/services/project_service.dart'];
  const actual=[...projects.matchAll(/\.where\('([^']+)',\s*isEqualTo:\s*([^)]+)\)/g)].map(m=>m[1]);
  assert.deepEqual(actual,['status','ownerId','applicantId','ownerId'],'service-query-shape-changed');
  assert(!/\.orderBy\s*\(/.test(projects),'new-server-ordering-needs-index-review');
  assert(projects.includes('FieldValue.arrayUnion([application.applicantId])'),'membership-write-contract');
  assert(projects.includes('_firestore.runTransaction')&&projects.includes('batch.commit()'),'atomic-write-contract');
  assert(sources['lib/services/firestore_service.dart'].includes('SetOptions(merge: true)'),'profile-merge-contract');
  for(const path of ['lib/models/app_user.dart','lib/models/project.dart','lib/models/project_application.dart']){
    assert(sources[path].includes('toMap()')&&sources[path].includes('fromMap('),'model-codec-missing:'+path);
  }
  return {mode:pinned?'pinned-feature-sources':'integrated-working-tree',observedEqualityQueries:actual.length,serverOrderBy:0};
}
