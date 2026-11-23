import Ajv from 'ajv/dist/2020.js';
import {readFileSync} from 'node:fs';
export const read = path => JSON.parse(readFileSync(new URL('../'+path,import.meta.url),'utf8'));
export const collections=['users','projects','applications'];
const ajv=new Ajv({strict:true,allErrors:true});
ajv.addKeyword({keyword:'x-codeUnits',type:'string',schemaType:'object',validate:(b,v)=>v.length>=b.min&&v.length<=b.max});
ajv.addKeyword({keyword:'x-trim',type:'string',schemaType:'boolean',validate:(enabled,v)=>!enabled||(v===v.trim()&&!v.startsWith('\u0085')&&!v.endsWith('\u0085'))});
export const schemas=Object.fromEntries(collections.map(c=>[c,read('contracts/'+c+'.schema.json')]));
const validators=Object.fromEntries(collections.map(c=>[c,ajv.compile(schemas[c])]));
export function validateCodec(c,value){const fn=validators[c];return {valid:!!fn&&fn(value),errors:fn?.errors??[]};}
export function assertCodec(c,value){const r=validateCodec(c,value);if(!r.valid)throw Error(c+':'+JSON.stringify(r.errors));}
