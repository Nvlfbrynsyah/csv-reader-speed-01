# CSV-READER-SPEED S1 — Fast Drop-in for CSV Reader 1.0.0

[![make.fun competition](https://img.shields.io/badge/make.fun-csv--reader--speed--01--run--20261121-blue)](https://make.fun)
[![repo](https://img.shields.io/badge/repo-Nvlfbrynsyah%2Fcsv--reader--speed--01-green)](https://github.com/Nvlfbrynsyah/csv-reader-speed-01)

## Overview
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
