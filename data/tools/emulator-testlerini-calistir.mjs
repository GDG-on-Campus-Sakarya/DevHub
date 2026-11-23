import {spawnSync} from 'node:child_process';
const suites=[['--test','--test-concurrency=1','--test-reporter=./tools/test-raporu.mjs','tests/emulator/guvenlik.test.mjs'],['tools/flutter-servislerini-calistir.mjs']];
for(const args of suites){const result=spawnSync(process.execPath,args,{encoding:'utf8',maxBuffer:32*1024*1024});process.stdout.write(result.stdout??'');process.stderr.write(result.stderr??'');if(result.status!==0){process.exitCode=1;break;}}
