import {spawnSync} from 'node:child_process';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {writeFileSync} from 'node:fs';
import assert from 'node:assert/strict';
const data=resolve(dirname(fileURLToPath(import.meta.url)),'..');
function run(name,args){
 const result=spawnSync(process.platform==='win32'?'flutter.bat':'flutter',args,{cwd:resolve(data,'..'),encoding:'utf8',shell:process.platform==='win32',maxBuffer:16*1024*1024});
 writeFileSync(resolve(data,'reports/'+name+'.log'),(result.stdout??'')+'\n'+(result.stderr??''));
 process.stdout.write(result.stdout??'');process.stderr.write(result.stderr??'');assert.equal(result.status,0,name);
 return result.stdout;
}
run('flutter-analyze',['analyze','--no-fatal-infos']);
const events=run('flutter-widget',['test','test/widget_test.dart','--reporter','json']);
const rows=events.split(/\r?\n/).flatMap(l=>{try{return[JSON.parse(l)];}catch{return[];}});
const tests=rows.filter(e=>e.type==='testDone'&&!e.hidden);assert.equal(tests.length,1);assert(tests.every(e=>e.result==='success'&&!e.skipped));
writeFileSync(resolve(data,'reports/uygulama-uyumu.json'),JSON.stringify({analysis:'PASS',existingWidgetSmoke:1,failed:0,fullUiEndToEnd:'NOT_RUN'},null,2)+'\n');
