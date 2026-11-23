import {test} from 'node:test';
import assert from 'node:assert/strict';
import {read,validateCodec,assertCodec} from '../../validation/sozlesme.mjs';
const rows=read('fixtures/model-ciktilari.json');
for(const row of rows)test(`codec:${row.collection}/${row.id} actual Dart map accepted`,()=>assertCodec(row.collection,row.data));
test('unknown collection fails closed',()=>assert.equal(validateCodec('other',{}).valid,false));
for(const row of rows)test(`codec:${row.collection}/${row.id} unknown field rejected`,()=>{
  assert.equal(validateCodec(row.collection,{...row.data,isAdmin:true}).valid,false);
});
test('optional user fields need no artificial schemaVersion/revision/timestamps',()=>{
  assertCodec('users',{name:'Ad',skills:[]});
  for(const field of ['schemaVersion','revision','createdAt'])assert.equal(validateCodec('users',{name:'Ad',skills:[],[field]:1}).valid,false);
});
for(const c of ['projects','applications'])test(`codec:${c} timestamps belong to service, not toMap`,()=>{
  const row=rows.find(r=>r.collection===c);assert.equal('createdAt' in row.data,false);assert.equal('updatedAt' in row.data,false);
});
for(const value of [1,true,null,{},['nested'],'x\ny','x'.repeat(201)])test(`invalid skill:${JSON.stringify(value).slice(0,30)}`,()=>{
  assert.equal(validateCodec('users',{name:'Ad',skills:[value]}).valid,false);
});
test('Dart UTF-16 bounds agree with validator for emoji',()=>{
  assertCodec('users',{name:'😀'.repeat(50),skills:[]});assert.equal(validateCodec('users',{name:'😀'.repeat(51),skills:[]}).valid,false);
});
test('actual UI display labels are accepted without old slug catalogs',()=>{
  const p=rows.find(r=>r.collection==='projects').data;assertCodec('projects',{...p,technologies:['C#','.NET','Node.js'],neededRoles:['UI/UX Tasarımcısı']});
});
test('optional project arrays remain compatible with model defaults',()=>{
  const p=rows.find(r=>r.collection==='projects').data;assertCodec('projects',{...p,technologies:[],neededRoles:[]});
});
for(const c of ['projects','applications'])test(`codec:${c} unknown status rejected`,()=>{
  const p=rows.find(r=>r.collection===c).data;assert.equal(validateCodec(c,{...p,status:'unknown'}).valid,false);
});
test('empty application message rejected',()=>{
  const a=rows.find(r=>r.collection==='applications').data;assert.equal(validateCodec('applications',{...a,message:''}).valid,false);
});
test('label limit is Unicode code points, separately from profile UTF-16',()=>{
  assertCodec('users',{name:'Ad',skills:['😀'.repeat(200)]});
  assert.equal(validateCodec('users',{name:'Ad',skills:['😀'.repeat(201)]}).valid,false);
});
test('service-normalized title/description/message reject blank or untrimmed payloads',()=>{
  const project=rows.find(r=>r.collection==='projects').data;
  const app=rows.find(r=>r.collection==='applications').data;
  for(const value of [' ', '\u00a0', '\u0085', '\ufeff', ' padded '])assert.equal(validateCodec('applications',{...app,message:value}).valid,false);
  assert.equal(validateCodec('projects',{...project,title:'   '}).valid,false);
  assert.equal(validateCodec('projects',{...project,description:' '.repeat(20)}).valid,false);
});
