# Baldinof RR Bundle Benchmark

## Goal

Compare the behavior of the original `baldinof/roadrunner-bundle`, the fixed version, and classic PHP-FPM when handling
streamed and binary file responses.

This project will prove that the fixed version correctly handles all types of streaming responses without worker
crashes, maintaining performance at the level of the original bundle and outperforming PHP-FPM in scenarios with long\
streams.

## Tested Configurations

| Runtime | Description                   | Port |
|---------|-------------------------------|------|
| rr      | Original bundle without fixes | 8000 |
| rr-fork | Modified version with fix     | 8001 |
| fpm     | Classic PHP-FPM (baseline)    | 8002 |

## Types of Tested Responses

| Path      | Response Type                     |
|-----------|-----------------------------------|
| `/`       | Generator-based Streamed Response |
| `/echo`   | Echo Callback Streamed Response	  |
| `/json`   | JSON Streamed Response            |
| `/file`   | Binary File Response              |
| `/common` | Common Response                   |

## Benchmarks

### Streamed

| Runtime  | Status   | Time         | Speed, M/s | Size, M    |
|----------|----------|--------------|------------|------------|
| rr       | ❌ 500    | 0.464        | 0          | 0          |
| rr-fork  | ✅ 200    | 0.410        | 153.4      | 62.8       |
| fpm      | ✅ 200    | 1.996        | 31.4       | 62.8       |

### Streamed echo

| Runtime  | Status   | Time         | Speed, M/s | Size, M    |
|----------|----------|--------------|------------|------------|
| rr       | ❌ 500    | 0.378        | 0          | 0          |
| rr-fork  | ✅ 200    | 0.385        | 163.1      | 62.8       |
| fpm      | ✅ 200    | 1.997        | 31.4       | 62.8       |

### Streamed json

| Runtime  | Status   | Time         | Speed, M/s | Size, M    |
|----------|----------|--------------|------------|------------|
| rr       | ❌ 500    | 0.445        | 0          | 0          |
| rr-fork  | ✅ 200    | 0.274        | 253.3      | 69.5       |
| fpm      | ✅ 200    | 0.288        | 241.5      | 69.5       |

### File

| Runtime  | Status   | Time         | Speed, M/s | Size, M    |
|----------|----------|--------------|------------|------------|
| rr       | ❌ 500    | 0.046        | 0          | 0          |
| rr-fork  | ✅ 200    | 0.057        | 1051.5     | 60.0       |
| fpm      | ✅ 200    | 0.082        | 730.5      | 60.0       |

### Common

| Runtime  | Status   | Time         | Speed, M/s | Size, M    |
|----------|----------|--------------|------------|------------|
| rr       | ✅ 200    | 0.010        | 0          | 0          |
| rr-fork  | ✅ 200    | 0.001        | 0          | 0          |
| fpm      | ✅ 200    | 0.002        | 0          | 0          |

## Running

Run benchmarks, using Docker Compose:

```bash
docker compose build && \
docker compose up -d && \
./benchmark.sh
```
