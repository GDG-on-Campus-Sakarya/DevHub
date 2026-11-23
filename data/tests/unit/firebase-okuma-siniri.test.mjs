import {test} from 'node:test';
import assert from 'node:assert/strict';
import {assertReadOnlyRequest as check} from '../../operations/lib/firebase-okuma-siniri.mjs';
const db='https://firestore.googleapis.com/v1/projects/devhub-34108/databases/(default)';
test('R01 shared metadata GET allowed',()=>assert.equal(check('https://firebase.googleapis.com/v1beta1/projects/devhub-34108'),'GET'));
test('R02 aggregate RPC is explicitly read-only POST',()=>assert.equal(check(db+'/documents:runAggregationQuery',{structuredAggregationQuery:{}}),'POST'));
test('R03 collection names RPC allowed',()=>assert.equal(check(db+'/documents:listCollectionIds',{pageSize:100}),'POST'));
test('R04 IAM permission test allowed, no IAM grant',()=>{
 assert.equal(check('https://cloudresourcemanager.googleapis.com/v1/projects/devhub-34108:testIamPermissions',{permissions:[]}), 'POST');
 assert.throws(()=>check('https://cloudresourcemanager.googleapis.com/v1/projects/devhub-34108:setIamPolicy',{policy:{}}));
});
for(const [name,url,body]of [
 ['other project','https://firebase.googleapis.com/v1beta1/projects/other-project'],
 ['plaintext transport','http://firebase.googleapis.com/v1beta1/projects/devhub-34108'],
 ['token exfiltration endpoint','https://example.invalid/v1beta1/projects/devhub-34108'],
 ['credential in URL','https://u:p@firebase.googleapis.com/v1beta1/projects/devhub-34108'],
 ['document payload read',db+'/documents/users/anything'],
 ['document write',db+'/documents:commit',{writes:[]}],
 ['Rules release write','https://firebaserules.googleapis.com/v1/projects/devhub-34108/releases/cloud.firestore',{rulesetName:'x'}],
 ['Auth config change','https://identitytoolkit.googleapis.com/admin/v2/projects/devhub-34108/config',{signIn:{}}],
 ['database create','https://firestore.googleapis.com/v1/projects/devhub-34108/databases',{locationId:'eur3'}],
 ['API enable','https://serviceusage.googleapis.com/v1/projects/903757169979/services/firestore.googleapis.com:enable',{}],
])test(`R-deny:${name}`,()=>assert.throws(()=>check(url,body)));
