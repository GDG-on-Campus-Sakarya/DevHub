import {test,before,beforeEach,after} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {initializeTestEnvironment,assertSucceeds,assertFails} from '@firebase/rules-unit-testing';
import {doc,setDoc,updateDoc,getDoc,getDocs,collection,query,where,writeBatch,serverTimestamp,Timestamp,deleteDoc,runTransaction,setLogLevel,arrayUnion} from 'firebase/firestore';
setLogLevel('silent');
const P='AbCdEfGhIjKlMnOpQrSt', Q='ZbCdEfGhIjKlMnOpQrSt';
const rows=JSON.parse(readFileSync(new URL('../../fixtures/model-ciktilari.json',import.meta.url)));
const base=c=>structuredClone(rows.find(r=>r.collection===c).data);
const stamp=()=>({createdAt:serverTimestamp(),updatedAt:serverTimestamp()});
const project=()=>({...base('projects'),...stamp()});
const application=(uid='bob')=>({...base('applications'),applicantId:uid,...stamp()});
let env;
const db=(uid,anonymous=false)=>uid?env.authenticatedContext(uid,{email:`${uid}@example.invalid`,firebase:{sign_in_provider:anonymous?'anonymous':'password'}}).firestore():env.unauthenticatedContext().firestore();
const pr=(store,id=P)=>doc(store,'projects',id);
const ar=(store,uid='bob',id=P)=>doc(store,'applications',`${id}_${uid}`);
const apatch=status=>({status,updatedAt:serverTimestamp()});
async function apply(uid='bob'){return setDoc(ar(db(uid),uid),application(uid));}
async function decide(status='accepted',uid='alice',applicant='bob'){
  const store=db(uid),batch=writeBatch(store);
  batch.update(ar(store,applicant),apatch(status));
  if(status==='accepted')batch.update(pr(store),{memberIds:arrayUnion(applicant),updatedAt:serverTimestamp()});
  return batch.commit();
}
before(async()=>{
  assert.equal(process.env.GCLOUD_PROJECT,'demo-devhub-mvp');
  assert.equal(process.env.FIRESTORE_EMULATOR_HOST,'127.0.0.1:8088');
  env=await initializeTestEnvironment({projectId:'demo-devhub-mvp',firestore:{host:'127.0.0.1',port:8088,rules:readFileSync(new URL('../../firestore/firestore.rules',import.meta.url),'utf8')}});
});
beforeEach(async()=>{
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async c=>{
    const b=writeBatch(c.firestore());
    const date=Timestamp.fromDate(new Date('2026-01-01T00:00:00Z'));
    b.set(pr(c.firestore()),{...base('projects'),createdAt:date,updatedAt:date});
    b.set(doc(c.firestore(),'users','alice'),base('users'));
    await b.commit();
  });
});
after(async()=>{await env?.cleanup();});

test('S01 own profile get and merge write use actual AppUser fields',async()=>{
  const s=db('alice');await assertSucceeds(getDoc(doc(s,'users','alice')));
  await assertSucceeds(setDoc(doc(s,'users','alice'),{...base('users'),bio:'Yeni açıklama'},{merge:true}));
  await assertSucceeds(setDoc(doc(db('minimal'),'users','minimal'),rows[1].data));
});
test('S02 foreign profile reads/writes and profile list are denied',async()=>{
  for(const uid of ['bob',null]){
    await assertFails(getDoc(doc(db(uid),'users','alice')));
    await assertFails(updateDoc(doc(db(uid),'users','alice'),{name:'Sahte'}));
  }
  await assertFails(getDocs(collection(db('alice'),'users')));
});
test('S03 email cannot differ from Auth email; unknown fields denied',async()=>{
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{email:'other@example.invalid'}));
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{isAdmin:true}));
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{email:null}));
});
test('S04 profile optional empty strings and full 50 labels fit Rules budget',async()=>{
  await assertSucceeds(updateDoc(doc(db('alice'),'users','alice'),{bio:'',department:'',githubUrl:'',skills:Array.from({length:50},(_,i)=>String(i).padStart(3,'0')+'x'.repeat(197))}));
});
test('S05 signed-in and anonymous users can read projects; signed-out cannot',async()=>{
  await assertSucceeds(getDoc(pr(db('bob'))));await assertSucceeds(getDoc(pr(db('guest',true))));
  await assertFails(getDoc(pr(db())));
});
test('S06 create uses live Auth owner, own-only member and service timestamps',async()=>{
  await assertSucceeds(setDoc(pr(db('alice'),Q),project()));
  await assertFails(setDoc(pr(db('bob'),Q),project()));
  await assertFails(setDoc(pr(db('alice'),'Y'.repeat(20)),{...project(),memberIds:['alice','bob']}));
});
test('S07 unauthenticated and anonymous contributions are denied',async()=>{
  for(const s of [db(),db('alice',true)])await assertFails(setDoc(pr(s,Q),project()));
  await assertFails(setDoc(ar(db('bob',true)),application()));
});
test('S08 owner update matches actual updateProject field set',async()=>{
  await assertSucceeds(updateDoc(pr(db('alice')),{title:'Yeni Proje',description:'Yeni proje açıklaması',technologies:[],neededRoles:[],status:'closed',updatedAt:serverTimestamp()}));
});
test('S09 non-owner project update denied',async()=>{
  await assertFails(updateDoc(pr(db('bob')),{title:'Sahte Proje',updatedAt:serverTimestamp()}));
});
test('S10 owner identity, name and createdAt cannot be rewritten',async()=>{
  for(const patch of [{ownerId:'bob'},{ownerName:'Sahte'},{createdAt:serverTimestamp()},{extra:true}])
    await assertFails(updateDoc(pr(db('alice')),{...patch,updatedAt:serverTimestamp()}));
});
test('S11 actual codec application plus service timestamps is accepted',async()=>{
  await assertSucceeds(apply());
  const a=(await getDoc(ar(db('bob')))).data();assert.equal(a.status,'pending');assert.equal(a.projectTitle,'DevHub');
});
test('S12 self application and spoofed applicant denied',async()=>{
  await assertFails(setDoc(ar(db('alice'),'alice'),application('alice')));
  await assertFails(setDoc(ar(db('charlie')),application()));
});
test('S13 arbitrary IDs and duplicate overwrite denied',async()=>{
  await assertFails(setDoc(doc(db('bob'),'applications','random'),application()));
  await apply();await assertFails(apply());
});
test('S14 concurrent duplicate transactions produce exactly one document',async()=>{
  const store=db('bob'),ref=ar(store);
  const create=()=>runTransaction(store,async tx=>{const snap=await tx.get(ref);if(snap.exists())throw Error('duplicate');tx.set(ref,application());});
  const results=await Promise.allSettled([create(),create()]);
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  assert.equal((await getDoc(ref)).data().applicantId,'bob');
});
test('S15 closed/missing project and stale owner/title denied by live Rules reads',async()=>{
  await assertFails(setDoc(ar(db('bob'),'bob',Q),{...application(),projectId:Q}));
  await assertFails(setDoc(ar(db('bob')),{...application(),ownerId:'charlie'}));
  await assertFails(setDoc(ar(db('bob')),{...application(),projectTitle:'Eski Başlık'}));
  await updateDoc(pr(db('alice')),{status:'closed',updatedAt:serverTimestamp()});await assertFails(apply());
});
test('S16 member cannot submit another application',async()=>{
  await env.withSecurityRulesDisabled(c=>updateDoc(pr(c.firestore()),{memberIds:['alice','bob']}));
  await assertFails(apply());
});
test('S17 own and owner application get allowed; unrelated denied',async()=>{
  await apply();await assertSucceeds(getDoc(ar(db('alice'))));await assertSucceeds(getDoc(ar(db('bob'))));
  await assertFails(getDoc(ar(db('charlie'))));await assertFails(getDoc(ar(db())));
});
test('S18 missing own stable ID can be read; arbitrary/foreign missing ID denied',async()=>{
  assert.equal((await assertSucceeds(getDoc(ar(db('bob'))))).exists(),false);
  await assertFails(getDoc(ar(db('charlie'))));
  await assertFails(getDoc(doc(db('bob'),'applications','random')));
  await assertSucceeds(getDoc(ar(db('bob_with_under'),'bob_with_under')));
});
test('S19 applicant cannot mutate or decide application',async()=>{
  await apply();for(const p of [{message:'Yeni mesaj'},apatch('accepted'),apatch('rejected')])await assertFails(updateDoc(ar(db('bob')),p));
});
test('S20 acceptance and member addition must be one atomic write',async()=>{
  await apply();await assertFails(updateDoc(ar(db('alice')),apatch('accepted')));
  await assertFails(updateDoc(pr(db('alice')),{memberIds:['alice','bob'],updatedAt:serverTimestamp()}));
  await assertSucceeds(decide());
  assert.equal((await getDoc(ar(db('bob')))).data().status,'accepted');
  assert.deepEqual((await getDoc(pr(db('alice')))).data().memberIds,['alice','bob']);
});
test('S21 rejection succeeds without membership; rejected cannot be added later',async()=>{
  await apply();await assertSucceeds(decide('rejected'));
  await assertFails(updateDoc(pr(db('alice')),{memberIds:['alice','bob'],updatedAt:serverTimestamp()}));
});
test('S22 stranger cannot decide with a forged batch',async()=>{
  await apply();await assertFails(decide('accepted','charlie'));await assertFails(decide('rejected','charlie'));
});
test('S23 terminal decisions are immutable; duplicate after rejection denied',async()=>{
  await apply();await decide('rejected');await assertFails(decide());await assertFails(apply());
});
test('S24 accepted member cannot be removed or replaced',async()=>{
  await apply();await decide();
  for(const memberIds of [['alice'],['bob'],['alice','charlie'],['alice','bob','charlie'],['alice','bob','bob']])
    await assertFails(updateDoc(pr(db('alice')),{memberIds,updatedAt:serverTimestamp()}));
});
test('S25 approval cannot edit message, identity or add extra members',async()=>{
  await apply();const s=db('alice'),b=writeBatch(s);
  b.update(ar(s),{...apatch('accepted'),message:'Sahte'});b.update(pr(s),{memberIds:['alice','bob'],updatedAt:serverTimestamp()});await assertFails(b.commit());
  const c=writeBatch(s);c.update(ar(s),apatch('accepted'));c.update(pr(s),{memberIds:['alice','bob','charlie'],updatedAt:serverTimestamp()});await assertFails(c.commit());
});
test('S26 pending creation cannot be changed to accepted in initial set',async()=>{
  await assertFails(setDoc(ar(db('bob')),{...application(),status:'accepted'}));
});
test('S27 concurrent accept/reject permits exactly one final decision',async()=>{
  await apply();const results=await Promise.allSettled([decide('accepted'),decide('rejected')]);
  assert.equal(results.filter(r=>r.status==='fulfilled').length,1);
  const status=(await getDoc(ar(db('bob')))).data().status;
  const members=(await getDoc(pr(db('alice')))).data().memberIds;
  assert.equal(members.includes('bob'),status==='accepted');
});
test('S28 profile/project/application deletion denied and unknown collections closed',async()=>{
  await apply();await assertFails(deleteDoc(doc(db('alice'),'users','alice')));await assertFails(deleteDoc(pr(db('alice'))));await assertFails(deleteDoc(ar(db('alice'))));
  await assertFails(setDoc(doc(db('alice'),'other','x'),{x:1}));await assertFails(getDoc(doc(db('alice'),'other','x')));
});
test('Q01-Q04 exact service queries work; unconstrained application query denied',async()=>{
  await apply();
  for(const [uid,c,field,value] of [['bob','projects','status','open'],['alice','projects','ownerId','alice'],['bob','applications','applicantId','bob'],['alice','applications','ownerId','alice']]){
    const result=await assertSucceeds(getDocs(query(collection(db(uid),c),where(field,'==',value))));assert.equal(result.size,1);
  }
  await assertFails(getDocs(collection(db('alice'),'applications')));
  await assertFails(getDocs(query(collection(db('charlie'),'applications'),where('applicantId','==','bob'))));
});
for(const [c,key,bad] of [
  ['users','name','a'.repeat(101)],['users','skills',[123]],['users','skills',[true]],['users','skills',[null]],['users','skills',[{}]],
  ['users','skills',['a\nb']],['users','skills',['x'.repeat(201)]],['users','skills',Array(51).fill('x')],
  ['projects','title','ab'],['projects','description','short'],['projects','technologies',[1]],['projects','neededRoles',[{}]],
  ['projects','status','archived'],['projects','createdAt','2026-01-01'],['applications','message',''],['applications','message','x'.repeat(501)],['applications','applicantName',42]
])test(`B:${c}.${key} rejects ${JSON.stringify(bad).slice(0,65)}`,async()=>{
  if(c==='users')await assertFails(updateDoc(doc(db('alice'),'users','alice'),{[key]:bad}));
  else if(c==='projects')await assertFails(setDoc(pr(db('alice'),Q),{...project(),[key]:bad}));
  else await assertFails(setDoc(ar(db('bob')),{...application(),[key]:bad}));
});
test('B unicode limits match Dart UTF-16 units; no artificial mandatory user metadata',async()=>{
  await assertSucceeds(updateDoc(doc(db('alice'),'users','alice'),{name:'😀'.repeat(50)}));
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{name:'😀'.repeat(51)}));
});
test('B raw past/future timestamps cannot replace server write time',async()=>{
  for(const time of [Timestamp.fromMillis(0),Timestamp.fromMillis(Date.now()+86400000)]){
    await assertFails(setDoc(pr(db('alice'),Q),{...project(),createdAt:time,updatedAt:time}));
    await assertFails(setDoc(ar(db('bob')),{...application(),createdAt:time,updatedAt:time}));
  }
});
test('B maximum project lists fit expression budget with legitimate owner update',async()=>{
  await assertSucceeds(updateDoc(pr(db('alice')),{technologies:Array(30).fill('x'.repeat(200)),neededRoles:Array(30).fill('y'.repeat(200)),updatedAt:serverTimestamp()}));
});
test('B label limits count Unicode code points and reject carriage return',async()=>{
  await assertSucceeds(updateDoc(doc(db('alice'),'users','alice'),{skills:['😀'.repeat(200)]}));
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{skills:['😀'.repeat(201)]}));
  await assertFails(updateDoc(doc(db('alice'),'users','alice'),{skills:['a\rb']}));
});
test('B full valid project and application still allow atomic acceptance within Rules budget',async()=>{
  await updateDoc(pr(db('alice')),{title:'t'.repeat(100),description:'d'.repeat(2000),technologies:Array(30).fill('x'.repeat(200)),neededRoles:Array(30).fill('y'.repeat(200)),updatedAt:serverTimestamp()});
  await setDoc(ar(db('bob')),{...application(),projectTitle:'t'.repeat(100),applicantName:'n'.repeat(200),message:'m'.repeat(500)});
  await assertSucceeds(decide());
});
test('B blank/untrimmed service payloads cannot bypass client normalization',async()=>{
  for(const message of [' ','\u00a0','\u0085','\ufeff',' padded '])await assertFails(setDoc(ar(db('bob')),{...application(),message}));
  await assertFails(setDoc(pr(db('alice'),Q),{...project(),title:'   '}));
  await assertFails(setDoc(pr(db('alice'),Q),{...project(),description:' '.repeat(20)}));
});
