# sqlite-ulid

Experimental SQLite extension for [ULIDs](https://github.com/ulid/spec), built on top of [sqlite-loadable-rs](https://github.com/asg017/sqlite-loadable-rs) and [ulid-rs](https://github.com/dylanhart/ulid-rs).

Still early in development, not meant to be widely shared. API subject to change heavily.

```sql
.load ./ulid0

select ulid(); -- '01GMRGH6F0VF2WGBR9JPBDK277'
select ulid_bytes(); -- X'0185310899dd7662b8f1e5adf9a5e7c0'
select ulid_with_prefix('invoice'); -- 'invoice_01GMRGH6F01DAKVTG9HJA19MP6'
select ulid_datetime('01GMP2G8ZG6PMKWYVKS62TTA41') -- 1671483106
```

## Quick benchmarks

Not definitive, hastily ran on a Macbook, not representative of real-life usecases. The `uuid()` SQL function comes from the [official `uuid.c` extension](https://sqlite.org/src/file/ext/misc/uuid.c).

| Test case                                      | Time                                            |
| ---------------------------------------------- | ----------------------------------------------- |
| `generate_series()` to generate 1 million rows | `28.5 ms ±   0.8 ms` (`1x`)                     |
| Calling `ulid_bytes()` 1 million times         | `88.4 ms ±   2.8 ms`,, `3.10 ± 0.13` slower     |
| Calling `uuid()` 1 million times               | `141.6 ms ±   1.5 ms`, or `4.97 ± 0.15` slower  |
| Calling `ulid()` 1 million times               | `344.3 ms ±  11.9 ms`, or `12.07 ± 0.53` slower |

So `ulid_bytes()` is pretty fast, but returns an unreadable blob instead of a nicely formatted text ID. The `ulid()` function does that, but is more than twice as slow than `uuid()`.

However, generating 1 million `ulid()` IDs in ~350ms is most likely "good enough" for most SQLite usecases.
