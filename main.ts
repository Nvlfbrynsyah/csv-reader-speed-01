import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { setFlagsFromString } from 'node:v8';

setFlagsFromString('--no-incremental-marking');

const { transduce, run } = await import('./solve.js');

const inputDir = process.env.MAKEFUN_INPUT_DIR ?? '/input';
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const raw = readFileSync(join(inputDir, 'cases.json'));
let out;
try {
  out = transduce(raw);
} catch {
  const casesData = JSON.parse(raw.toString('utf8'));
  out = Buffer.from(JSON.stringify(casesData.map((c) => run(c.input))), 'utf8');
}
writeFileSync(join(outputDir, 'answers.json'), out);
