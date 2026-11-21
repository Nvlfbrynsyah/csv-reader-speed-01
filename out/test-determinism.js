import { execSync } from 'node:child_process';
import { readFileSync, rmSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';

const out1 = join(import.meta.dirname, 'out1');
const out2 = join(import.meta.dirname, 'out2');

mkdirSync(out1, { recursive: true });
mkdirSync(out2, { recursive: true });

execSync(`MAKEFUN_INPUT_DIR=${import.meta.dirname} MAKEFUN_OUTPUT_DIR=${out1} node main.ts`, { stdio: 'inherit' });
execSync(`MAKEFUN_INPUT_DIR=${import.meta.dirname} MAKEFUN_OUTPUT_DIR=${out2} node main.ts`, { stdio: 'inherit' });

// Note: cases.json is in out/, so MAKEFUN_INPUT_DIR points to out/ (where cases.json is located)
// Wait, in main.ts, it expects cases.json in INPUT_DIR.
// Let's check where cases.json is: it's in out/cases.json.
// In our test, import.meta.dirname is out/, so MAKEFUN_INPUT_DIR=out.

const ans1 = readFileSync(join(out1, 'answers.json'), 'utf8');
const ans2 = readFileSync(join(out2, 'answers.json'), 'utf8');

rmSync(out1, { recursive: true, force: true });
rmSync(out2, { recursive: true, force: true });

if (ans1 === ans2) {
  console.log('Determinism check PASSED: output answers.json files are byte-identical.');
} else {
  console.error('Determinism check FAILED: output files differ!');
  process.exit(1);
}
