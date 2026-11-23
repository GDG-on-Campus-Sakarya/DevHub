import {spawnSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync,copyFileSync,existsSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';

const data=resolve(dirname(fileURLToPath(import.meta.url)),'..'), repo=resolve(data,'..');
const pinned=process.argv.includes('--pinned');
const registry=JSON.parse(readFileSync(resolve(data,'validation/kaynaklar.json')));
const work=resolve(data,'reports/flutter-codec'); mkdirSync(work,{recursive:true});
const files=[];
for(const row of registry.files){
  const raw=pinned?spawnSync('git',['show',`${row.commit}:${row.path}`],{cwd:repo}).stdout:readFileSync(resolve(repo,row.path));
  assert(raw?.length,'missing-source:'+row.path);
  const sha256=createHash('sha256').update(raw).digest('hex');
  if(pinned)assert.equal(sha256,row.sha256,'pinned-source-hash:'+row.path);
  files.push({path:row.path,sha256,commit:pinned?row.commit:null});
  if(row.path.startsWith('lib/models/')){
    const dst=resolve(work,row.path);mkdirSync(dirname(dst),{recursive:true});writeFileSync(dst,raw);
  }
}
copyFileSync(resolve(repo,'pubspec.yaml'),resolve(work,'pubspec.yaml'));
if (existsSync(resolve(repo,'pubspec.lock'))) copyFileSync(resolve(repo,'pubspec.lock'),resolve(work,'pubspec.lock'));
mkdirSync(resolve(work,'test'),{recursive:true});
copyFileSync(resolve(data,'tests/flutter/model_sozlesmesi_test.dart'),resolve(work,'test/model_sozlesmesi_test.dart'));
// Flutter is an executable .bat on Windows. The command is fixed; no user text is interpolated.
function flutter(args){
  const exe=process.platform==='win32'?'flutter.bat':'flutter';
  const r=spawnSync(exe,args,{cwd:work,encoding:'utf8',shell:process.platform==='win32',maxBuffer:16*1024*1024});
  writeFileSync(resolve(data,'reports','flutter-'+args[0]+'.log'),(r.stdout??'')+'\n'+(r.stderr??''));
  process.stdout.write(r.stdout??'');process.stderr.write(r.stderr??'');
  if(r.status!==0)throw Error('flutter '+args.join(' ')+' failed: '+(r.status??r.error));
  return r.stdout;
}
flutter(['pub','get']);
const events=flutter(['test','--reporter','json']);
writeFileSync(resolve(data,'reports/flutter-events.jsonl'),events);
const generated=JSON.parse(readFileSync(resolve(work,'codec-ciktilari.json')));
const expected=resolve(data,'fixtures/model-ciktilari.json');
if(process.argv.includes('--update-fixtures')){
  mkdirSync(dirname(expected),{recursive:true});
  writeFileSync(expected,JSON.stringify(generated,null,2)+'\n');
}
else assert.deepEqual(generated,JSON.parse(readFileSync(expected)),'codec-fixture-drift');
const parsed=events.split(/\r?\n/).flatMap(line=>{try{return [JSON.parse(line)];}catch{return [];}});
const cases=parsed.filter(e=>e.type==='testDone'&&e.hidden!==true);
assert(cases.length>=10,'missing-dart-test-evidence');
assert(cases.every(e=>e.result==='success'&&!e.skipped),'dart-test-failure-or-skip');
const report={scope:'real Dart model codec tests; service/UI integration not executed',mode:pinned?'pinned-feature-sources':'integrated-working-tree',checkedOn:new Date().toISOString(),files,tests:cases.length,failed:0,fixtureMatch:true};
writeFileSync(resolve(data,'reports/flutter-uyumu.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify(report));
