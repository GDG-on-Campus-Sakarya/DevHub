import {spawnSync} from 'node:child_process';
import {resolve,dirname,relative} from 'node:path';
import {fileURLToPath} from 'node:url';
import {readFileSync,readdirSync,writeFileSync,mkdirSync,existsSync} from 'node:fs';
import {createHash} from 'node:crypto';
import assert from 'node:assert/strict';
const data=resolve(dirname(fileURLToPath(import.meta.url)),'..');
assert.equal(process.versions.node.split('.')[0],'24','Node.js 24.x required');
assert(!process.argv.includes('--pinned'),'Full verify requires integrated lib sources; pinned mode is only available for test:flutter.');
function hash(){const h=createHash('sha256');function walk(dir){for(const e of readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name))){
  if(['node_modules','reports','.firebase'].includes(e.name)||e.name.endsWith('.log'))continue;const p=resolve(dir,e.name);
  if(e.isDirectory())walk(p);else h.update(relative(data,p).replaceAll('\\','/')+'\0').update(readFileSync(p));
}}walk(data);walk(resolve(data,'../lib'));walk(resolve(data,'../test'));for(const p of ['../firebase.json','../.firebaserc','../analysis_options.yaml','../pubspec.yaml','../.github/workflows/data.yml','../.github/workflows/flutter.yml'])h.update(p).update(readFileSync(resolve(data,p)));if(existsSync(resolve(data,'../pubspec.lock')))h.update('../pubspec.lock').update(readFileSync(resolve(data,'../pubspec.lock')));return h.digest('hex');}
const sourceHash=hash(),id=new Date().toISOString().replaceAll(':','-');
const reports=resolve(data,'reports',id);mkdirSync(reports,{recursive:true});
const steps=[];
function run(name,exe,args){const r=spawnSync(exe,args,{cwd:data,encoding:'utf8',maxBuffer:32*1024*1024,env:{...process.env,CI:'true'}});
  writeFileSync(resolve(reports,name+'.log'),(r.stdout??'')+'\n'+(r.stderr??''));
  process.stdout.write(`${name}: ${r.status===0?'PASS':'FAIL'}\n`);
  if(r.status!==0)process.stderr.write(((r.stdout??'')+'\n'+(r.stderr??'')).slice(-6000));
  steps.push({name,status:r.status===0?'PASS':'FAIL',exitCode:r.status,error:r.error?.message??null});
  return r.status===0;
}
const sequence=[
  ['application',process.execPath,['tools/uygulamayi-dogrula.mjs']],
  ['flutter-codec',process.execPath,['tools/flutter-uyumunu-calistir.mjs']],
  ['static',process.execPath,['validation/paket.mjs']],
  ['unit',process.execPath,['--test','--test-reporter=./tools/test-raporu.mjs',...readdirSync(resolve(data,'tests/unit')).filter(f=>f.endsWith('.test.mjs')).sort().map(f=>'tests/unit/'+f)]],
  ['emulator',process.execPath,['node_modules/firebase-tools/lib/bin/firebase.js','emulators:exec','--config','firebase.json','--project','demo-devhub-mvp','--only','auth,firestore','node tools/emulator-testlerini-calistir.mjs']],
  ['audit',process.execPath,[process.env.npm_execpath||resolve(dirname(process.execPath),'node_modules/npm/bin/npm-cli.js'),'audit','--json']]
];
for(const [name,exe,args]of sequence)if(!run(name,exe,args))break;
const tests=[];
for(const step of steps.filter(s=>['unit','emulator'].includes(s.name))){
  const log=readFileSync(resolve(reports,step.name+'.log'),'utf8');
  for(const line of log.split(/\r?\n/)){try{const e=JSON.parse(line);if(e.kind==='case')tests.push({...e,suite:step.name});}catch{}}
}
const changed=sourceHash!==hash();
const required=Array.from({length:28},(_,i)=>`S${String(i+1).padStart(2,'0')} `).concat(['Q01-Q04 ']);
const coverage=required.every(prefix=>tests.some(t=>t.suite==='emulator'&&t.status==='PASS'&&t.name.startsWith(prefix)));
const load=name=>existsSync(resolve(data,'reports',name))?JSON.parse(readFileSync(resolve(data,'reports',name),'utf8')):null;
const service=load('flutter-servis-uyumu.json'),codec=load('flutter-uyumu.json'),application=load('uygulama-uyumu.json');
const live=load('firebase-son-durum.json');
const serviceFresh=service&&Date.parse(service.checkedAt)>=Date.parse(id.replace(/T(\d\d)-(\d\d)-(\d\d)/,'T$1:$2:$3'));
const serviceResults=serviceFresh&&Array.isArray(service.results)?service.results:[];
for(const result of serviceResults){
  tests.push({kind:'case',name:result.name,status:result.status,error:result.errors?.join('; ')??null,suite:'dart-services'});
}
const counts={unit:tests.filter(t=>t.suite==='unit'&&t.status==='PASS').length,rules:tests.filter(t=>t.suite==='emulator'&&t.status==='PASS').length,dartCodec:codec?.tests??0,dartServices:serviceResults.length,existingWidget:application?.existingWidgetSmoke??0};
const nodeFailures=tests.filter(t=>['unit','emulator'].includes(t.suite)&&t.status==='FAIL').length;
const serviceFailures=serviceResults.filter(t=>t.status!=='PASS').length;
const serviceRunnerFailure=serviceFresh&&service.runnerExitCode!==0?1:0;
const failed=nodeFailures+Math.max(serviceFailures,serviceRunnerFailure);
const nodeTests=tests.filter(t=>['unit','emulator'].includes(t.suite)&&t.status==='PASS').length;
const report={runId:id,checkedAt:new Date().toISOString(),mode:'integrated-working-tree',sourceHash,sourceUnchanged:!changed,steps,tests,localTestCounts:counts,totalLocalTests:Object.values(counts).reduce((a,b)=>a+b,0),
  nodeTests,failed,
  requiredSecurityCasesCovered:coverage,
  result:steps.length===6&&steps.every(s=>s.status==='PASS')&&!changed&&coverage&&counts.unit>=41&&serviceFresh&&counts.dartServices===10&&service.failed===0&&service.runnerExitCode===0&&tests.every(t=>t.status==='PASS')?'PASS':'FAIL',
  sharedProjectId:'devhub-34108',
  remoteEvidence:live?{checkedAt:live.checkedAt,projectId:live.projectId,summary:live.summary,performedByThisCommand:false,report:'firebase-son-durum.json',sha256:createHash('sha256').update(readFileSync(resolve(data,'reports/firebase-son-durum.json'))).digest('hex')}:null,
  accountAccess:live?.checks.project?.status==='PASS'?'VERIFIED_AT_ATTACHED_CHECK_TIME':'NOT_CHECKED_BY_LOCAL_VERIFY',
  realIndexValidation:live?.summary?.queryShapesAccepted?'QUERY_SHAPES_VERIFIED_VIA_IAM_AT_ATTACHED_CHECK_TIME':'NOT_CHECKED_BY_LOCAL_VERIFY',
  uiIntegration:'EXISTING_WIDGET_SMOKE_ONLY_FULL_UI_NOT_RUN',deployed:false,productionReady:false};
writeFileSync(resolve(reports,'sonuc.json'),JSON.stringify(report,null,2)+'\n');writeFileSync(resolve(data,'reports/son-kosum.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({runId:id,result:report.result,sourceHash,tests:report.nodeTests,failed:report.failed,report:relative(data,resolve(reports,'sonuc.json'))}));
if(report.result!=='PASS')process.exitCode=1;
