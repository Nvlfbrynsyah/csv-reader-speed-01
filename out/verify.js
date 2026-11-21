import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { run } from '../solve.js';
import { readCsv as referenceReadCsv } from './reference.js';

const casesPath = join(import.meta.dirname, 'cases.json');
const expectedPath = join(import.meta.dirname, 'expected.json');

const cases = JSON.parse(readFileSync(casesPath, 'utf8'));
const expected = JSON.parse(readFileSync(expectedPath, 'utf8'));

console.log(`Running verification on ${cases.length} cases...`);

let failed = false;
for (let i = 0; i < cases.length; i++) {
  const c = cases[i];
  const expOutput = expected.cases[i].output;

  const solOutput = run(c.input);
  const refOutput = referenceReadCsv(c.input);

  const solStr = JSON.stringify(solOutput);
  const refStr = JSON.stringify(refOutput);
  const expStr = JSON.stringify(expOutput);

  if (solStr !== expStr) {
    console.error(`[FAIL] Case ${c.id} (index ${i}) does not match expected!`);
    console.error('Expected:', expStr.slice(0, 200));
    console.error('Got:', solStr.slice(0, 200));
    failed = true;
  }
  if (solStr !== refStr) {
    console.error(`[FAIL] Case ${c.id} (index ${i}) does not match reference!`);
    failed = true;
  }
}

// Edge cases test suite
const edgeCases = [
  { name: 'empty text', input: { text: '', header: false } },
  { name: 'only BOM', input: { text: '\uFEFF', header: false } },
  { name: 'header true no records', input: { text: '', header: true } },
  { name: 'header true BOM only', input: { text: '\uFEFF', header: true } },
  { name: 'unterminated quote', input: { text: 'a,"b,c\nd,e', header: false } },
  { name: 'quote junk', input: { text: '"a"foo,bar', header: false } },
  { name: 'stray CRs', input: { text: 'a\rb,c\r\nd,e', header: false } },
  { name: 'lone CR only line', input: { text: '\r\r\na,b', header: false } },
  { name: 'short and long rows', input: { text: 'a,b,c\nd\na,b,c,d', header: true } },
  { name: 'CRLF inside quotes', input: { text: '"a\r\nb",c', header: false } },
  { name: 'doubled quotes', input: { text: '"a""b",c', header: false } },
  { name: 'quote at end of text', input: { text: 'a,"b"', header: false } },
  { name: 'empty quoted field as only record', input: { text: '""', header: false } },
  { name: 'empty unquoted field as only record', input: { text: '', header: false } },
];

for (const ec of edgeCases) {
  const sol = run(ec.input);
  const ref = referenceReadCsv(ec.input);
  if (JSON.stringify(sol) !== JSON.stringify(ref)) {
    console.error(`[FAIL] Edge case "${ec.name}" does not match reference!`);
    console.error('Ref:', JSON.stringify(ref));
    console.error('Sol:', JSON.stringify(sol));
    failed = true;
  }
}

if (failed) {
  console.error('Verification FAILED.');
  process.exit(1);
} else {
  console.log('ALL verification checks passed successfully!');
}
