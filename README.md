# csv-reader-speed-01

[![make.fun · csv-reader-speed-01-run-20261121](https://make.fun/badge/csv-reader-speed-01-run-20261121.svg)](https://make.fun/bounty/csv-reader-speed-01-run-20261121?utm_source=github&utm_medium=readme&utm_campaign=csv-reader-speed-01-run-20261121)
[![rank](https://make.fun/badge/csv-reader-speed-01-run-20261121/Nvlfbrynsyah/csv-reader-speed-01/rank.svg)](https://make.fun/bounty/csv-reader-speed-01-run-20261121/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=csv-reader-speed-01-run-20261121)
[![reward](https://make.fun/badge/csv-reader-speed-01-run-20261121/Nvlfbrynsyah/csv-reader-speed-01/reward.svg)](https://make.fun/bounty/csv-reader-speed-01-run-20261121?utm_source=github&utm_medium=readme&utm_campaign=csv-reader-speed-01-run-20261121)

A high-performance, dependency-free ES module drop-in replacement for `csv-reader` 1.0.0, built for the make.fun speed competition. It produces exact semantic parity (columns, rows, errors, edge cases) while significantly outperforming the reference parser.

## How to Run
```bash
export MAKEFUN_INPUT_DIR=/path/to/input
export MAKEFUN_OUTPUT_DIR=/path/to/output
node main.ts
```

## Speed Optimizations
- **Optimized Scanning**: Uses `charCodeAt` and fast `indexOf` position skipping rather than per-character traversal loops.
- **Efficient Slicing**: Extracts field values via `slice()` instead of character-by-character string accumulation.
- **Pure & Lightweight**: Zero external dependencies, zero state retention across calls, and optimized V8 execution flags.
