export default async function* report(source){
  for await(const e of source)if(['test:pass','test:fail'].includes(e.type)){
    yield JSON.stringify({kind:'case',name:e.data.name,file:e.data.file,status:e.data.skip?'SKIP':e.data.todo?'TODO':e.type==='test:pass'?'PASS':'FAIL',durationMs:e.data.details?.duration_ms??null,error:e.data.details?.error?.message??null})+'\n';
  }
}
