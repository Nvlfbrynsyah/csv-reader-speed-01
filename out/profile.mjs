import { readFileSync } from 'node:fs';
import * as ref from './reference.js';
const mine = await import('../solve.js');
const cases = JSON.parse(readFileSync('out/cases.json','utf8'));
function bench(fn, label){
  const times=[];
  for(let r=0;r<3;r++){
    const t0=process.hrtime.bigint();
    for(const c of cases) fn(c.input);
    times.push(Number(process.hrtime.bigint()-t0)/1e6);
  }
  console.log(label, times.map(t=>t.toFixed(0)+'ms').join(' '));
  return times;
}
const a=bench(ref.readCsv,'reference run() only:');
const b=bench(mine.run,'mine      run() only:');
console.log('speedup (median):', (a.sort((x,y)=>x-y)[1]/b.sort((x,y)=>x-y)[1]).toFixed(2)+'x');
// per-case
for(const c of cases){
  const t0=process.hrtime.bigint(); ref.readCsv(c.input); const t1=process.hrtime.bigint();
  mine.run(c.input); const t2=process.hrtime.bigint();
  const q=(c.input.text.match(/"/g)||[]).length, cr=(c.input.text.match(/\r/g)||[]).length;
  console.log(c.id, 'ref', Number(t1-t0)/1e6|0, 'ms mine', Number(t2-t1)/1e6|0, 'ms | quotes:', q, 'CRs:', cr, 'len:', c.input.text.length);
}
// JSON overhead
const t0=process.hrtime.bigint(); JSON.parse(readFileSync('out/cases.json','utf8')); console.log('JSON.parse cases:', Number(process.hrtime.bigint()-t0)/1e6|0,'ms');
