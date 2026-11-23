import {createRequire} from 'node:module';
import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {assertReadOnlyRequest} from './lib/firebase-okuma-siniri.mjs';

// Explicit read-only inspection. Never invoke from CI or normal verify.
const data=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const project='devhub-34108', number='903757169979';
const require=createRequire(import.meta.url);
const auth=require('firebase-tools/lib/auth.js');
const scopes=require('firebase-tools/lib/scopes.js');
const account=auth.getProjectDefaultAccount(resolve(data,'..'));
if(!account)throw Error('Firebase CLI login required; do not supply credentials in arguments.');
const {access_token:token}=await auth.getAccessToken(account.tokens.refresh_token,[scopes.CLOUD_PLATFORM]);
if(!token)throw Error('No valid CLI access token.');
const folder=resolve(data,'reports/firebase',new Date().toISOString().replaceAll(':','-'));
mkdirSync(folder,{recursive:true});
const report={checkedAt:new Date().toISOString(),projectId:project,identitySource:'Firebase CLI active account; credentials never exported',remoteMutations:0,checks:{},scope:'Metadata, Rules, indexes and aggregate counts only. OAuth IAM calls do not test client Security Rules.'};
async function request(id,url,body){
  const method=assertReadOnlyRequest(url,body);
  const response=await fetch(url,{method,headers:{Authorization:`Bearer ${token}`,'Content-Type':'application/json'},body:body?JSON.stringify(body):undefined,signal:AbortSignal.timeout(30000)});
  const value=await response.json();
  report.checks[id]={status:response.ok?'PASS':'UNAVAILABLE',httpStatus:response.status};
  if(!response.ok){report.checks[id].error={status:value.error?.status??'UNKNOWN',message:String(value.error?.message??'').slice(0,700)};return null;}
  return value;
}
const p=await request('project',`https://firebase.googleapis.com/v1beta1/projects/${project}`);
if(p)report.checks.project.observed={projectId:p.projectId,projectNumber:p.projectNumber,displayName:p.displayName,state:p.state};
const apps=await request('apps',`https://firebase.googleapis.com/v1beta1/projects/${project}/webApps`);
if(apps)report.checks.apps.observed=(apps.apps??[]).map(a=>({appId:a.appId,displayName:a.displayName,state:a.state}));
const localOptions=readFileSync(resolve(data,'../lib/firebase_options.dart'),'utf8');
const localAppId=localOptions.match(/appId:\s*'([^']+)'/)?.[1];
if(localAppId&&apps?.apps?.some(a=>a.appId===localAppId)){
  const sdk=await request('sdkConfig',`https://firebase.googleapis.com/v1beta1/projects/${project}/webApps/${localAppId}/config`);
  if(sdk)report.checks.sdkConfig.observed={projectIdMatches:sdk.projectId===project,appIdMatches:sdk.appId===localAppId,apiKeyMatches:sdk.apiKey===localOptions.match(/apiKey:\s*'([^']+)'/)?.[1],valuesExported:false};
}
const dbs=await request('databases',`https://firestore.googleapis.com/v1/projects/${project}/databases`);
if(dbs)report.checks.databases.observed=(dbs.databases??[]).map(d=>({name:d.name,locationId:d.locationId,type:d.type,databaseEdition:d.databaseEdition,deleteProtectionState:d.deleteProtectionState,pointInTimeRecoveryEnablement:d.pointInTimeRecoveryEnablement}));
const permissions=['firebase.projects.get','datastore.databases.get','datastore.indexes.list','datastore.entities.get','datastore.entities.list','firebaserules.releases.get','firebaserules.rulesets.get','firebaseauth.configs.get','firebasehosting.sites.list'];
const iam=await request('iam',`https://cloudresourcemanager.googleapis.com/v1/projects/${project}:testIamPermissions`,{permissions});
if(iam)report.checks.iam.observed={tested:permissions,granted:iam.permissions??[]};
const release=await request('rulesRelease',`https://firebaserules.googleapis.com/v1/projects/${project}/releases/cloud.firestore`);
if(release){
  report.checks.rulesRelease.observed={name:release.name,rulesetName:release.rulesetName,updateTime:release.updateTime};
  const ruleset=await request('rulesSource',`https://firebaserules.googleapis.com/v1/${release.rulesetName}`);
  if(ruleset){
    const source=(ruleset.source?.files??[]).map(f=>f.content).join('\n');
    writeFileSync(resolve(folder,'yayinlanan-kurallar.rules'),source);
    report.checks.rulesSource.observed={sha256:createHash('sha256').update(source).digest('hex'),files:(ruleset.source?.files??[]).map(f=>f.name),sourceStoredLocally:true};
  }
}
async function paged(id,url,key){
  const items=[];let next;
  do{
    const u=new URL(url);if(next)u.searchParams.set('pageToken',next);
    const v=await request(id,u.href);if(!v)return null;items.push(...(v[key]??[]));next=v.nextPageToken;
    if(items.length>1000)throw Error('metadata-page-limit');
  }while(next);
  return items;
}
const database=`projects/${project}/databases/(default)`;
if(dbs?.databases?.some(d=>d.name===database)){
  const indexes=await paged('indexes',`https://firestore.googleapis.com/v1/${database}/collectionGroups/-/indexes`,'indexes');
  if(indexes){report.checks.indexes.observed=indexes;}
  const fields=await paged('fields',`https://firestore.googleapis.com/v1/${database}/collectionGroups/-/fields?filter=${encodeURIComponent('indexConfig.usesAncestorConfig=false OR ttlConfig:*')}`,'fields');
  if(fields)report.checks.fields.observed=fields.map(f=>({name:f.name,indexConfig:f.indexConfig,ttlConfig:f.ttlConfig}));
  const cols=await request('collections',`https://firestore.googleapis.com/v1/${database}/documents:listCollectionIds`,{pageSize:100});
  if(cols)report.checks.collections.observed={ids:cols.collectionIds??[],complete:!cols.nextPageToken};
  const inventory=[['Q01','projects','status','open'],['Q02','projects','ownerId','__devhub_inspection_no_user__'],['Q03','applications','applicantId','__devhub_inspection_no_user__'],['Q04','applications','ownerId','__devhub_inspection_no_user__']];
  for(const [id,collection,field,value]of inventory){
    const result=await request(id,`https://firestore.googleapis.com/v1/${database}/documents:runAggregationQuery`,{structuredAggregationQuery:{structuredQuery:{from:[{collectionId:collection}],where:{fieldFilter:{field:{fieldPath:field},op:'EQUAL',value:{stringValue:value}}}},aggregations:[{count:{},alias:'n'}]}});
    if(result){
      const countValue=result.find?.(r=>r.result)?.result?.aggregateFields?.n?.integerValue??result.result?.aggregateFields?.n?.integerValue;
      if(countValue===undefined||!Number.isSafeInteger(Number(countValue))||Number(countValue)<0)throw Error('aggregate-count-response-invalid:'+id);
      report.checks[id].observed={collection,filter:field,operator:'==',authentication:'OAuth IAM, not Firebase application Auth',count:Number(countValue)};
    }
  }
}else report.databaseDependentChecks='NOT_RUN_NO_ACCESSIBLE_DEFAULT_DATABASE';
const config=await request('authConfig',`https://identitytoolkit.googleapis.com/admin/v2/projects/${project}/config`);
if(config)report.checks.authConfig.observed={authorizedDomains:config.authorizedDomains??[],signIn:{emailEnabled:config.signIn?.email?.enabled??false,passwordRequired:config.signIn?.email?.passwordRequired??null,anonymousEnabled:config.signIn?.anonymous?.enabled??false},multiTenantAllowed:config.multiTenant?.allowTenants??false};
const sites=await request('hosting',`https://firebasehosting.googleapis.com/v1beta1/projects/${project}/sites`);
if(sites)report.checks.hosting.observed=(sites.sites??[]).map(s=>({name:s.name,defaultUrl:s.defaultUrl,type:s.type}));
const appcheck=await request('appCheck',`https://firebaseappcheck.googleapis.com/v1beta/projects/${number}/services`);
if(appcheck)report.checks.appCheck.observed=(appcheck.services??[]).map(s=>({name:s.name,enforcementMode:s.enforcementMode}));
report.summary={metadataChecks:Object.keys(report.checks).length,allHttpChecksPassed:Object.values(report.checks).every(c=>c.status==='PASS'),queryShapesAccepted:['Q01','Q02','Q03','Q04'].every(id=>report.checks[id]?.status==='PASS'),clientRulesValidatedRemotely:false,remoteMutations:0};
writeFileSync(resolve(folder,'firebase-durumu.json'),JSON.stringify(report,null,2)+'\n');
writeFileSync(resolve(data,'reports/firebase-son-durum.json'),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({report:folder,checks:Object.fromEntries(Object.entries(report.checks).map(([k,v])=>[k,{status:v.status,httpStatus:v.httpStatus,observed:['project','databases','collections','authConfig','iam'].includes(k)?v.observed:undefined,error:v.error}]))},null,2));
