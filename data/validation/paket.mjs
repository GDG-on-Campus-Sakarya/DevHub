import assert from 'node:assert/strict';
import {readFileSync,readdirSync,existsSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {read,assertCodec,collections,schemas} from './sozlesme.mjs';
import {inspectApplication} from './uygulama-uyumu.mjs';
const data=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const json=p=>JSON.parse(readFileSync(resolve(data,p),'utf8'));
const root=json('../firebase.json'),alias=json('../.firebaserc');
assert.equal(alias.projects.default,'devhub-34108');
const target=read('validation/firebase-hedefi.json');
assert.equal(target.project.projectId,alias.projects.default);
assert.equal(target.database.name,'projects/devhub-34108/databases/(default)');
assert.equal(target.database.locationId,'eur3');
assert.equal(target.database.type,'FIRESTORE_NATIVE');
assert.equal(target.remoteWrites,0);
assert.equal(target.sdkConfig.projectIdMatches&&target.sdkConfig.appIdMatches&&target.sdkConfig.apiKeyMatches,true);
assert.equal(target.indexes.composites,0);assert.equal(target.indexes.customFieldOverrides,0);
assert.deepEqual(root.flutter,{platforms:{dart:{'lib/firebase_options.dart':{projectId:'devhub-34108',configurations:{web:'1:903757169979:web:8db8d1b1d5bed7b6a1631e'}}}}});
assert.deepEqual(root.firestore,{rules:'data/firestore/firestore.rules',indexes:'data/firestore/firestore.indexes.json'});
assert(!existsSync(resolve(data,'../firestore.rules')),'second-active-rules-source-at-root');
assert.deepEqual(read('firestore/firestore.indexes.json'),{indexes:[],fieldOverrides:[]});
const emulator=read('firebase.json');assert.equal(emulator.emulators.firestore.host,'127.0.0.1');
assert.equal(emulator.firestore.rules,'firestore/firestore.rules');
assert.equal(emulator.firestore.indexes,'firestore/firestore.indexes.json');
const rows=read('fixtures/model-ciktilari.json');for(const row of rows)assertCodec(row.collection,row.data);
assert.deepEqual([...new Set(rows.map(r=>r.collection))].sort(),[...collections].sort());
const rules=readFileSync(resolve(data,'firestore/firestore.rules'),'utf8');
for(const c of collections){
  const name=c==='users'?'User':c==='projects'?'Project':'Application';
  const section=rules.split(`function valid${name}(d)`)[1]?.split('\n    }')[0];assert(section);
  const wireKeys=[...schemas[c].required,...(c==='users'?[]:['createdAt','updatedAt'])];
  const all=[...section.matchAll(/hasAll\(\[([^\]]*)\]\)/g)][0][1].match(/'[^']+'/g).map(s=>s.slice(1,-1));
  const only=[...section.matchAll(/hasOnly\(\[([^\]]*)\]\)/g)][0][1].match(/'[^']+'/g).map(s=>s.slice(1,-1));
  assert.deepEqual(all.sort(),wireKeys.sort(),'required-wire-fields:'+c);
  assert.deepEqual(only.sort(),[...Object.keys(schemas[c].properties),...(c==='users'?[]:['createdAt','updatedAt'])].sort(),'allowed-wire-fields:'+c);
}
const docs=[];
function walk(dir){for(const item of readdirSync(dir,{withFileTypes:true})){
  if(['node_modules','reports','.git'].includes(item.name))continue;
  const p=resolve(dir,item.name);if(item.isDirectory())walk(p);else if(p.endsWith('.md'))docs.push(p);
  else assert(!/\.(png|jpg|pdf|webp)$/i.test(p),'design-assets-in-data:'+p);
}}
walk(data);
let links=0;
for(const p of docs){for(const m of readFileSync(p,'utf8').matchAll(/\[[^\]]*\]\(([^)]+)\)/g)){
  if(/^(?:https?:|#)/.test(m[1]))continue;
  const target=decodeURIComponent(m[1].split('#')[0]);assert(existsSync(resolve(dirname(p),target)),'broken-link:'+p+':'+target);links++;
}}
const service=inspectApplication(process.argv.includes('--pinned'));
console.log(JSON.stringify({status:'PASS',scope:'local static checks; no remote Firebase verification',documents:docs.length,links,codecFixtures:rows.length,service}));
