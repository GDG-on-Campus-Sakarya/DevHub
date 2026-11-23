import {spawnSync} from 'node:child_process';
import {readFileSync} from 'node:fs';
import {resolve,dirname,sep} from 'node:path';
import {createHash} from 'node:crypto';

// Flutter 3.47.7's local CanvasKit handler compares a Windows path with '/'.
// Serve only the unmodified SDK JS/WASM assets to our own headless test browser.
// No application requests, Firebase calls, test results or global SDK files change.
export function windowsTestAssets(){
 if(process.platform!=='win32')return {observe(){},close(){},evidence:[]};
 const found=spawnSync('where.exe',['flutter.bat'],{encoding:'utf8'}).stdout?.trim().split(/\r?\n/)[0];
 if(!found)throw Error('flutter-path-required');
 const root=resolve(dirname(found),'../bin/cache/flutter_web_sdk/canvaskit');
 const evidence=[];let socket,started=false,buffer='';
 async function attach(port){
   const targets=await fetch(`http://127.0.0.1:${port}/json/list`).then(r=>r.json());
   const page=targets.find(t=>t.type==='page'&&/^http:\/\/localhost:\d+\/static\/index.html/.test(t.url));
   if(!page)throw Error('owned-test-page-missing');
   socket=new WebSocket(page.webSocketDebuggerUrl);
   await new Promise((ok,bad)=>{socket.addEventListener('open',ok,{once:true});socket.addEventListener('error',bad,{once:true});});
   let id=1;const send=(method,params)=>socket.send(JSON.stringify({id:id++,method,params}));
   socket.addEventListener('message',e=>{
     const m=JSON.parse(e.data);if(m.method!=='Fetch.requestPaused')return;
     const u=new URL(m.params.request.url),local=resolve(root,u.pathname.replace(/^\/canvaskit\//,''));
     if(!local.startsWith(root+sep)||!u.pathname.startsWith('/canvaskit/')||!/\.(?:js|wasm)$/.test(local)){
       send('Fetch.continueRequest',{requestId:m.params.requestId});return;
     }
     const bytes=readFileSync(local);
     evidence.push({asset:u.pathname,sha256:createHash('sha256').update(bytes).digest('hex')});
     send('Fetch.fulfillRequest',{requestId:m.params.requestId,responseCode:200,responseHeaders:[{name:'Content-Type',value:local.endsWith('.wasm')?'application/wasm':'text/javascript'}],body:bytes.toString('base64')});
   });
   send('Fetch.enable',{patterns:[{urlPattern:'http://localhost:*/canvaskit/*',requestStage:'Request'}]});
 }
 return {evidence,observe(chunk){
   if(started)return;buffer=(buffer+String(chunk)).slice(-6000);
   const match=buffer.match(/DevTools listening on ws:\/\/127\.0\.0\.1:(\d+)/);
   if(match){started=true;attach(match[1]).catch(e=>{evidence.push({error:String(e.message??e)});});}
 },close(){if(socket&&socket.readyState<2)socket.close();}};
}
