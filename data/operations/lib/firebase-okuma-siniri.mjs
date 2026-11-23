const project='devhub-34108';
const routes={
 'firebase.googleapis.com':/^\/v1beta1\/projects\/devhub-34108(?:\/webApps(?:\/[^/]+\/config)?)?$/,
 'firebaserules.googleapis.com':/^\/v1\/projects\/devhub-34108\/(?:releases\/cloud\.firestore|rulesets\/[^/]+)$/,
 'firestore.googleapis.com':/^\/v1\/projects\/devhub-34108\/databases(?:\/\(default\)\/collectionGroups\/-\/(?:indexes|fields))?$/,
 'identitytoolkit.googleapis.com':/^\/admin\/v2\/projects\/devhub-34108\/config$/,
 'firebasehosting.googleapis.com':/^\/v1beta1\/projects\/devhub-34108\/sites$/,
 'firebaseappcheck.googleapis.com':/^\/v1beta\/projects\/903757169979\/services$/,
};
export function assertReadOnlyRequest(url,body){
 const u=new URL(url);
 if(u.protocol!=='https:'||u.username||u.password||u.port||u.hash)throw Error('endpoint-not-allowed');
 if(body){
   const firestore=u.hostname==='firestore.googleapis.com'&&new RegExp(`^/v1/projects/${project}/databases/\\(default\\)/documents:(?:listCollectionIds|runAggregationQuery)$`).test(u.pathname);
   const iam=u.hostname==='cloudresourcemanager.googleapis.com'&&u.pathname===`/v1/projects/${project}:testIamPermissions`;
   if(!firestore&&!iam)throw Error('mutation-not-allowed');
   return 'POST';
 }
 if(!routes[u.hostname]?.test(u.pathname))throw Error('endpoint-not-allowed');
 return 'GET';
}
