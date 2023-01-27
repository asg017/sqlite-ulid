# sqlite-ulid Documentation

A full reference to every function and module that sqlite-ulid offers.

As a reminder, sqlite-ulid follows semver and is pre v1, so breaking changes are to be expected.

## API Reference

<h3 name="ulid"><code>ulid([id])</code></h3>

When no arguments are given, then `ulid()` generates a new lower-cased 26-character ULID string.

```sql
select ulid(); -- '01gqrdes0hyscqpxf1yjm6m3r9'
select ulid(); -- '01gqrdeseemx2mwnfg932phz1k'
select ulid(); -- '01gqrdessdnxd9pf2p2vp3jfpp'
```

If the `id` argument is given, it is assumed that it's a BLOB return from the [`ulid_bytes()`](#ulid_bytes) function. Then it'll return the TEXT representation of that BLOB, which is typically more human-readable at the expense of slightly more storage (26 bytes vs 10).

```sql
select ulid(ulid_bytes()); -- '01gqrdr8z1z1fadk6c11zkk7cw'
select ulid(X'0185f0dc8ec7613cfa43034128935a60'); -- '01gqrds3p7c4yfmgr384m96pk0'
```

Keep in mind, while `sqlite-ulid` uses lowercase ULIDs, technically ULIDs are case-insensitive. If you're comparing or sorting text ULIDs, consider using the `nocase` collation for accurate results.

```sql
select '01GMP2G8ZG6PMKWYVKS62TTA41' == '01gmp2g8zg6pmkwyvks62tta41'; -- 0
select '01GMP2G8ZG6PMKWYVKS62TTA41' == '01gmp2g8zg6pmkwyvks62tta41' collate nocase; -- 1
```

<h3 name="ulid_bytes"><code>ulid_bytes([id])</code></h3>

If no arguments are given, then `ulid_bytes()` generates a new blob ULID. This is slightly faster to generate than a string ULID, and more compact than the [`ulid()`](#ulid) counterpart.

```sql
select ulid_bytes(); -- X'0185d0c5362761312e0483e4c9e3ec5d'
select ulid_bytes(); -- X'0185d0c538679350f9262bf16fd575f7'
```

If the `id` argument is given, it's assumed to be an text ULID, in which `ulid_bytes()` will generate the BLOB representation of that ULID.

```sql
select ulid_bytes('01gqrdes0hyscqpxf1yjm6m3r9'); -- X'0185f0d76411f6597b75e1f4a86a0f09'
select ulid_bytes('01gqrdeseemx2mwnfg932phz1k'); -- X'0185f0d765cea7454e55f048c568fc33'
```

Note: the `id` argument cannot be a ULID generated with [`ulid_with_prefix()`](#ulid_with_prefix), as there's no straightforward way to make a binary representation of that.

<h3 name="ulid_with_prefix"><code>ulid_with_prefix(prefix)</code></h3>

Generates a new ULID string with the given `prefix`, with an underscore between. A nice utility to have when you want to discern the difference between multiple ULIDs of different items, like [Stripe's many ID types](https://gist.github.com/fnky/76f533366f75cf75802c8052b577e2a5).

```sql
select ulid_with_prefix('invoice'); -- 'invoice_01gqre8x2efy50mz28b238dh2a'
select ulid_with_prefix('invoice'); -- 'invoice_01gqre8xc36045w1qekg404g0m'

select ulid_with_prefix('cus'); -- 'cus_01gqre97xwey5jd694tkg3ncg9'
select ulid_with_prefix('card'); -- 'card_01gqre9c6az7835tdk00wc0gfp'
```

<h3 name="ulid_datetime"><code>ulid_datetime(ulid)</code></h3>

Extract the timestamp component from the given ULID. The `ulid` parameter can be a string from the [`ulid()](#ulid) function, a string from the [`ulid_with_prefix()`](#ulid_with_prefix) function, or a blob from the [`ulid_bytes`](#ulid_bytes) function. Returns an integer as the

```sql
select ulid_datetime('01GQ8C8FWG0W1B5H3W5304049S'); -- '2023-01-20 20:00:00.400'
select ulid_datetime(X'0185d0c5362761312e0483e4c9e3ec5d'); -- '2023-01-20 20:01:03.527'
select ulid_datetime('invoice_01gqre8x2efy50mz28b238dh2a'); -- '2023-01-27 01:43:01.966'
```

<h3 name="ulid_version"><code>ulid_version()</code></h3>

Returns the semver version string of the current version of `sqlite-ulid`.

```sql
select ulid_version(); -- 'v0.1.0'
```

<h3 name="ulid_debug"><code>ulid_debug()</code></h3>

Returns a debug string of various info about `sqlite-ulid`, including
the version string, build date, and commit hash.

```sql
select ulid_debug();
'Version: v0.1.0
Source: 247dca8f4cea1abdc30ed3e852c3e5b71374c177'
```
