import {spawn,spawnSync} from 'node:child_process';
import {readFileSync,writeFileSync,mkdirSync,copyFileSync,appendFileSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {windowsTestAssets} from './lib/windows-test-assets.mjs';
const data=resolve(dirname(fileURLToPath(import.meta.url)),'..'),repo=resolve(data,'..');
assert.equal(process.env.GCLOUD_PROJECT,'demo-devhub-mvp');
assert.equal(process.env.FIRESTORE_EMULATOR_HOST,'127.0.0.1:8088');
assert.equal(process.env.FIREBASE_AUTH_EMULATOR_HOST,'127.0.0.1:9098');
const work=resolve(data,'reports/flutter-service');mkdirSync(work,{recursive:true});
const registry=JSON.parse(readFileSync(resolve(data,'validation/kaynaklar.json'))),files=[];
for(const row of registry.files){
  const raw=readFileSync(resolve(repo,row.path));const dst=resolve(work,row.path);mkdirSync(dirname(dst),{recursive:true});writeFileSync(dst,raw);
  files.push({path:row.path,sha256:createHash('sha256').update(raw).digest('hex')});
}
for(const name of ['pubspec.yaml','pubspec.lock'])copyFileSync(resolve(repo,name),resolve(work,name));
const pubspec=resolve(work,'pubspec.yaml');
writeFileSync(pubspec,readFileSync(pubspec,'utf8').replace('dev_dependencies:',`dev_dependencies:
  flutter_web_plugins:
    sdk: flutter
  firebase_core_web: 2.24.1
  firebase_auth_web: 5.15.3
  cloud_firestore_web: 4.4.12`));
mkdirSync(resolve(work,'test'),{recursive:true});copyFileSync(resolve(data,'tests/flutter/servis_entegrasyon_test.dart'),resolve(work,'test/servis_entegrasyon_test.dart'));
let assetEvidence=[];
async function flutter(args,{allowFailure=false}={}){
  const log=resolve(data,'reports/flutter-service-'+args[0]+'.log');writeFileSync(log,'');
  const child=spawn(process.platform==='win32'?'flutter.bat':'flutter',args,{cwd:work,shell:process.platform==='win32',env:{...process.env,CI:'true'}});
  const assets=windowsTestAssets();
  let output='';child.stdout.on('data',chunk=>{assets.observe(chunk);output+=chunk;appendFileSync(log,chunk);process.stdout.write(chunk);});
  child.stderr.on('data',chunk=>{assets.observe(chunk);appendFileSync(log,chunk);process.stderr.write(chunk);});
  const timer=setTimeout(()=>{
    if(process.platform==='win32')spawnSync('taskkill.exe',['/PID',String(child.pid),'/T','/F']);else child.kill('SIGKILL');
  },720000);
  const status=await new Promise((ok,bad)=>{child.on('error',bad);child.on('close',ok);}).finally(()=>{clearTimeout(timer);assets.close();assetEvidence=assets.evidence;});
  if(!allowFailure)assert.equal(status,0,'flutter-service-'+args[0]);
  return {output,status};
}
await flutter(['pub','get']);
const testRun=await flutter(['test','test/servis_entegrasyon_test.dart','--platform','chrome','--reporter','json','--no-pub','--verbose'],{allowFailure:true});
const events=testRun.output;
writeFileSync(resolve(data,'reports/flutter-service-events.jsonl'),events);
const rows=events.split(/\r?\n/).flatMap(line=>{try{return[JSON.parse(line)];}catch{return[];}});
const starts=rows.filter(e=>e.type==='testStart'&&e.test?.line!==null&&e.test?.line!==undefined&&!e.test.name.startsWith('('));
const tests=rows.filter(e=>e.type==='testDone'&&!e.hidden);
const results=starts.map(start=>{
  const id=start.test.id,done=tests.find(e=>e.testID===id),errors=rows.filter(e=>e.type==='error'&&e.testID===id);
  return {name:start.test.name,status:done?.result==='success'&&!done.skipped&&errors.length===0?'PASS':'FAIL',
    ...(errors.length?{errors:errors.map(e=>e.error)}:{})};
});
const testFailures=results.filter(r=>r.status!=='PASS').length;
const failed=Math.max(testFailures,testRun.status===0?0:1);
const suiteErrors=rows.filter(e=>e.type==='error'&&(e.testID===undefined||e.testID===null)).map(e=>e.error);
const report={checkedAt:new Date().toISOString(),scope:'Actual production Dart services through Chrome + local Firebase Auth/Firestore Emulator',projectId:'demo-devhub-mvp',sharedProjectWrites:0,tests:results.length,failed,runnerExitCode:testRun.status,suiteErrors,results,files,windowsSdkAssetCompatibility:assetEvidence};
writeFileSync(resolve(data,'reports/flutter-servis-uyumu.json'),JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
assert.equal(starts.length,10,'all-ten-service-scenarios-required');
assert.equal(tests.length,10,'each-service-test-must-finish');
assert.equal(suiteErrors.length,0,'service-suite-must-not-emit-unscoped-errors');
assert.equal(testRun.status,0,'flutter-service-test-runner-must-exit-successfully');
assert.equal(failed,0,'all-service-scenarios-must-pass');
