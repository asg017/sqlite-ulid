#!/bin/bash
hyperfine --warmup=10 \
  'sqlite3x :memory: "select count(value) from generate_series(1, 1e6);"' \
  'sqlite3x :memory: ".load target/release/libulid0" "select count(ulid_bytes()) from generate_series(1, 1e6);"' \
  'sqlite3x :memory: ".load ./uuid" "select count(uuid()) from generate_series(1, 1e6);"' \
  'sqlite3x :memory: ".load target/release/libulid0" "select count(ulid()) from generate_series(1, 1e6);"'
  