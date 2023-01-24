# sqlite-ulid Documentation

A full reference to every function and module that sqlite-ulid offers.

As a reminder, sqlite-ulid follows semver and is pre v1, so breaking changes are to be expected.

## API Reference

<h3 name="ulid"><code>ulid()</code></h3>

Generates a new ULID string.

```sql
select ulid(); -- '01GQ8C8FWG0W1B5H3W5304049S'
select ulid(); -- '01GQ8C8GEEP2HS0MR3SWRWF1Q7'
select ulid(); -- '01GQ8C8GXHQHJ1ZW04F2MNP0ET'
```

```sql
select ulid_bytes('01GMP2G8ZG6PMKWYVKS62TTA41') == ulid_bytes('01gmp2g8zg6pmkwyvks62tta41');
select '01GMP2G8ZG6PMKWYVKS62TTA41' == '01gmp2g8zg6pmkwyvks62tta41';
select '01GMP2G8ZG6PMKWYVKS62TTA41' == '01gmp2g8zg6pmkwyvks62tta41' collate nocase;
```

<h3 name="ulid_bytes"><code>ulid_bytes()</code></h3>

Generates a new blob ULID. Is slightly faster to generate than a string ULID, and more compact than the [`ulid()`](#ulid) counterpart.

```sql
select ulid_bytes(); -- X'0185d0c5362761312e0483e4c9e3ec5d'
select ulid_bytes(); -- X'0185d0c538679350f9262bf16fd575f7'
select ulid_bytes(); -- X'0185d0c53a037f80b4c15595d90a0448'
select ulid_bytes(); -- X'0185d0c5362761312e0483e4c9e3ec5d'
```

<h3 name="ulid_with_prefix"><code>ulid_with_prefix(prefix)</code></h3>

Generates a new ULID string with the given `prefix`, with an underscore between. A nice utility to have when you want to discern the difference between multiple ULIDs of different items, like [Stripe's many ID types](https://gist.github.com/fnky/76f533366f75cf75802c8052b577e2a5).

```sql
select ulid_with_prefix('invoice'); -- 'invoice_01GQ8EGHGXEE0XMACGPJT7KJNR'
select ulid_with_prefix('invoice'); -- 'invoice_01GQ8EGHXFZQTEGGFXXDY5S24J'

select ulid_with_prefix('cus'); -- 'cus_01GQ8EH3CJFM468BWSR2E4812T'
select ulid_with_prefix('card'); -- 'card_01GQ8EH6PHCF1ZCTGH10DHT3G9'
```

<h3 name="ulid_datetime"><code>ulid_datetime(ulid)</code></h3>

Extract the timestamp component from the given ULID. The `ulid` parameter can either be a string from the [`ulid()](#ulid) function of a blob from the [`ulid_bytes`](#ulid_bytes) function. Returns an integer as the

```sql
select ulid_datetime('01GQ8C8FWG0W1B5H3W5304049S'); -- ''
select ulid_datetime(X'0185d0c5362761312e0483e4c9e3ec5d'); -- ''


select strftime('', '1674244800400', );
```

<h3 name="ulid_debug"><code>ulid_debug()</code></h3>

Returns a debug string of various info about `sqlite-ulid`, including
the version string, build date, and commit hash.

```sql
select ulid_debug();
'Version: v0.1.0
Source: 247dca8f4cea1abdc30ed3e852c3e5b71374c177'
```

<h3 name="ulid_version"><code>ulid_version()</code></h3>

Returns the semver version string of the current version of `sqlite-ulid`.

```sql
select ulid_version(); -- 'v0.1.0'
```
