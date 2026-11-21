import { readFileSync } from 'node:fs';
import * as ref from './reference.js';
const mine = await import('../solve.js');
const cases = JSON.parse(readFileSync('out/cases.json','utf8'));
const expected = JSON.parse(readFileSync('out/expected.json','utf8'));
// correctness first
let ok = true;
for (let i=0;i<cases.length;i++){
  const got = mine.run(cases[i].input);
  if (JSON.stringify(got) !== JSON.stringify(expected.cases[i].output)) { console.log('MISMATCH', cases[i].id); ok=false; }
}
console.log('correctness 6/6:', ok);
// warmup
for(let r=0;r<2;r++) for(const c of cases){ ref.readCsv(c.input); mine.run(c.input); }
// interleaved reps
const reps=7, refT={}, myT={};
for(const c of cases){ refT[c.id]=[]; myT[c.id]=[]; }
for(let r=0;r<reps;r++){
  for(const c of cases){
    let t0=process.hrtime.bigint(); ref.readCsv(c.input); refT[c.id].push(Number(process.hrtime.bigint()-t0)/1e6);
    t0=process.hrtime.bigint(); mine.run(c.input); myT[c.id].push(Number(process.hrtime.bigint()-t0)/1e6);
  }
}
const med=a=>a.slice().sort((x,y)=>x-y)[Math.floor(a.length/2)];
let rt=0, mt=0;
for(const c of cases){
  const r=med(refT[c.id]), m=med(myT[c.id]); rt+=r; mt+=m;
  console.log(c.id, 'ref', r.toFixed(0)+'ms', 'mine', m.toFixed(0)+'ms', (r/m).toFixed(2)+'x');
}
console.log('TOTAL ref', rt.toFixed(0)+'ms mine', mt.toFixed(0)+'ms speedup', (rt/mt).toFixed(2)+'x');
