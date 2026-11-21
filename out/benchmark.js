import { readFileSync, mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { performance } from 'node:perf_hooks';
import { run as optimizedRun } from '../solve.js';
import { readCsv as referenceRun } from './reference.js';

const casesPath = join(import.meta.dirname, 'cases.json');
const cases = JSON.parse(readFileSync(casesPath, 'utf8'));

// Warmup
for (const c of cases) {
  optimizedRun(c.input);
  referenceRun(c.input);
}

const ITERATIONS = 5;

// Benchmark Reference (Baseline)
let refTotalTime = 0;
for (let iter = 0; iter < ITERATIONS; iter++) {
  const start = performance.now();
  for (const c of cases) {
    referenceRun(c.input);
  }
  const end = performance.now();
  refTotalTime += (end - start);
}
const refAvg = refTotalTime / ITERATIONS;

// Benchmark Optimized (Ours)
let optTotalTime = 0;
for (let iter = 0; iter < ITERATIONS; iter++) {
  const start = performance.now();
  for (const c of cases) {
    optimizedRun(c.input);
  }
  const end = performance.now();
  optTotalTime += (end - start);
}
const optAvg = optTotalTime / ITERATIONS;

console.log(`Baseline (Reference) average time: ${refAvg.toFixed(2)} ms`);
console.log(`Optimized (Ours) average time: ${optAvg.toFixed(2)} ms`);
console.log(`Speedup factor: ${(refAvg / optAvg).toFixed(2)}x faster`);
