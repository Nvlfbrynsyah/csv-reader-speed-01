import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, join } from 'node:path';
import { setFlagsFromString } from 'node:v8';

setFlagsFromString('--no-incremental-marking');

const { run } = await import('./solve.js');

const inputDir = process.env.MAKEFUN_INPUT_DIR ?? '/input';
const outputDir = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const casesData = JSON.parse(readFileSync(join(inputDir, 'cases.json'), 'utf8'));
const results = [];

for (const entry of casesData) {
  results.push(run(entry.input));
}

writeFileSync(join(outputDir, 'answers.json'), JSON.stringify(results));
