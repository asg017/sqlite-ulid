# sqlite-ulid

A SQLite extension for generating and working with [ULIDs](https://github.com/ulid/spec). Built on top of [sqlite-loadable-rs](https://github.com/asg017/sqlite-loadable-rs) and [ulid-rs](https://github.com/dylanhart/ulid-rs).

If your company or organization finds this library useful, consider [supporting my work](#supporting)!

## Usage

```sql
.load ./ulid0

select ulid(); -- '01gqr4j69cc7w1xdbarkcbpq17'
select ulid_bytes(); -- X'0185310899dd7662b8f1e5adf9a5e7c0'
select ulid_with_prefix('invoice'); -- 'invoice_01gqr4jmhxhc92x1kqkpxb8j16'
select ulid_with_datetime('2023-01-26 22:53:20.556); -- '01gqr4j69cc7w1xdbarkcbpq17'
select ulid_datetime('01gqr4j69cc7w1xdbarkcbpq17') -- '2023-01-26 22:53:20.556'
```

Use as a `PRIMARY KEY` for a table.

```sql
create table log_events(
  id ulid primary key,
  data any
);


insert into log_events(id, data) values (ulid(), 1);
insert into log_events(id, data) values (ulid(), 2);
insert into log_events(id, data) values (ulid(), 3);

select * from log_events;
/*
┌────────────────────────────┬──────┐
│             id             │ data │
├────────────────────────────┼──────┤
│ 01gqr4vr487bytsf10ktfmheg4 │ 1    │
│ 01gqr4vr4dfcfk80m2yp6j866z │ 2    │
│ 01gqr4vrjxg0yex9jr0f100v1c │ 3    │
└────────────────────────────┴──────┘
*/
```

Consider using [`ulid_bytes()`](./docs.md#ulid_bytes) for speed and smaller IDs. They generate about 1.6x faster than `ulid()`, and take up 16 bytes instead of 26 bytes. You can use `ulid()` to create a text representation of a BLOB ULID.

```sql

create table log_events(
  id ulid primary key,
  data any
);


insert into log_events(id, data) values (ulid_bytes(), 1);
insert into log_events(id, data) values (ulid_bytes(), 2);
insert into log_events(id, data) values (ulid_bytes(), 3);

select hex(id), ulid(id), data from log_events;
/*
┌──────────────────────────────────┬────────────────────────────┬──────┐
│             hex(id)              │          ulid(id)          │ data │
├──────────────────────────────────┼────────────────────────────┼──────┤
│ 0185F0539EBF286DA9F56BA4D9981783 │ 01gqr577nz51ptkxbbmkcsg5w3 │ 1    │
│ 0185F0539EC54F85745C1ECB64DF3A97 │ 01gqr577p59y2q8q0ysdjdyemq │ 2    │
│ 0185F0539ED48113F6F67BF3F6A4BFF7 │ 01gqr577pmg49zdxkvyfva9fzq │ 3    │
└──────────────────────────────────┴────────────────────────────┴──────┘
*/
```

Extract the timestamp component of a ULID with [`ulid_datetime()`](./docs.md#ulid_datetime).

```sql
select ulid_datetime(ulid()); -- '2023-01-26 23:07:36.508'
select unixepoch(ulid_datetime(ulid())); -- 1674774499
select strftime('%Y-%m-%d', ulid_datetime(ulid())); -- '2023-01-26''
```

Consider using [`ulid_with_prefix()`](./docs.md#ulid_with_prefix) to generate a text ULID with a given prefix, to differentiate between different ID types.

```sql
select ulid_with_prefix('customer'); -- 'customer_01gqr5j1ebk31wv30wgp8ebehj'
select ulid_with_prefix('product'); -- 'product_01gqr5prjgsa77dhrxf2dt1dgv'
select ulid_with_prefix('order'); -- 'order_01gqr5q35n68jk0sycy1ntr083'


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

## Using with...

| Language       | Install                                                      |                                                                                                                                                                                             |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Python         | `pip install sqlite-ulid`                                    | [![PyPI](https://img.shields.io/pypi/v/sqlite-ulid.svg?color=blue&logo=python&logoColor=white)](https://pypi.org/project/sqlite-ulid/)                                                      |
| Datasette      | `datasette install datasette-sqlite-ulid`                    | [![Datasette](https://img.shields.io/pypi/v/datasette-sqlite-ulid.svg?color=B6B6D9&label=Datasette+plugin&logoColor=white&logo=python)](https://datasette.io/plugins/datasette-sqlite-ulid) |
| Node.js        | `npm install sqlite-ulid`                                    | [![npm](https://img.shields.io/npm/v/sqlite-ulid.svg?color=green&logo=nodedotjs&logoColor=white)](https://www.npmjs.com/package/sqlite-ulid)                                                |
| Deno           | [`deno.land/x/sqlite_ulid`](https://deno.land/x/sqlite_ulid) | [![deno.land/x release](https://img.shields.io/github/v/release/asg017/sqlite-ulid?color=fef8d2&include_prereleases&label=deno.land%2Fx&logo=deno)](https://deno.land/x/sqlite_ulid)        |
| Ruby           | `gem install sqlite-ulid`                                    | ![Gem](https://img.shields.io/gem/v/sqlite-ulid?color=red&logo=rubygems&logoColor=white)                                                                                                    |
| Rust           | `cargo add sqlite-ulid`                                      | [![Crates.io](https://img.shields.io/crates/v/sqlite-ulid?logo=rust)](https://crates.io/crates/sqlite-ulid)                                                                                 |
| Github Release |                                                              | ![GitHub tag (latest SemVer pre-release)](https://img.shields.io/github/v/tag/asg017/sqlite-ulid?color=lightgrey&include_prereleases&label=Github+release&logo=github)                      |

<!--
| Elixir         | [`hex.pm/packages/sqlite_ulid`](https://hex.pm/packages/sqlite_ulid) | [![Hex.pm](https://img.shields.io/hexpm/v/sqlite_ulid?color=purple&logo=elixir)](https://hex.pm/packages/sqlite_ulid)                                                                       |
| Go             | `go get -u github.com/asg017/sqlite-ulid/bindings/go`               | [![Go Reference](https://pkg.go.dev/badge/github.com/asg017/sqlite-ulid/bindings/go.svg)](https://pkg.go.dev/github.com/asg017/sqlite-ulid/bindings/go)                                     |
-->

The [Releases page](https://github.com/asg017/sqlite-ulid/releases) contains pre-built binaries for Linux x86_64, MacOS, and Windows.

### Python

For Python developers, install the [`sqlite-ulid` package](https://pypi.org/package/sqlite-ulid/) with:

```
pip install sqlite-ulid
```

```python
import sqlite3
import sqlite_ulid
db = sqlite3.connect(':memory:')
db.enable_load_extension(True)
sqlite_ulid.load(db)
db.execute('select ulid()').fetchone()
# ('01gr7gwc5aq22ycea6j8kxq4s9',)
```

See [`python/sqlite_ulid`](./python/sqlite_ulid/README.md) for more details.

### Node.js

For Node.js developers, install the [`sqlite-ulid` npm package](https://www.npmjs.com/package/sqlite-ulid) with:

```
npm install sqlite-ulid
```

```js
import Database from "better-sqlite3";
import * as sqlite_ulid from "sqlite-ulid";

const db = new Database(":memory:");
db.loadExtension(sqlite_ulid.getLoadablePath());
```

See [`npm/sqlite-ulid/README.md`](./npm/sqlite-ulid/README.md) for more details.

### Deno

For [Deno](https://deno.land/) developers, use the [deno.land/x/sqlite_ulid](https://deno.land/x/sqlite_ulid) module:

```ts
import { Database } from "https://deno.land/x/sqlite3@0.8.0/mod.ts";
import * as sqlite_ulid from "https://deno.land/x/sqlite_ulid@v${VERSION}/mod.ts";

const db = new Database(":memory:");

db.enableLoadExtension = true;
sqlite_ulid.load(db);

const [version] = db.prepare("select ulid_version()").value<[string]>()!;

console.log(version);
```

### Datasette

And for [Datasette](https://datasette.io/), install the [`datasette-sqlite-ulid` plugin](https://datasette.io/plugins/datasette-sqlite-ulid) with:

```
datasette install datasette-sqlite-ulid
```

See [`python/datasette_sqlite_ulid`](./python/datasette_sqlite_ulid/README.md) for more details.

### As a loadable extension

If you want to use `sqlite-ulid` as a [Runtime-loadable extension](https://www.sqlite.org/loadext.html), Download the `ulid0.dylib` (for MacOS), `ulid0.so` (Linux), or `ulid0.dll` (Windows) file [from a release](https://github.com/asg017/sqlite-ulid/releases) and load it into your SQLite environment.

> **Note:**
> The `0` in the filename (`ulid0.dylib`/ `ulid0.so`/`ulid0.dll`) denotes the major version of `sqlite-ulid`. Currently `sqlite-ulid` is pre v1, so expect breaking changes in future versions.

For example, if you are using the [SQLite CLI](https://www.sqlite.org/cli.html), you can load the library like so:

```sql
.load ./ulid0
select ulid_version();
-- v0.1.0
```

In Python, you should prefer the [`sqlite-ulid` Python package](./python/sqlite_ulid/README.md). However, you can manually load a pre-compiled extension with the builtin [sqlite3 module](https://docs.python.org/3/library/sqlite3.html):

```python
import sqlite3
con = sqlite3.connect(":memory:")
con.enable_load_extension(True)
con.load_extension("./ulid0")
print(con.execute("select ulid_version()").fetchone())
# ('v0.1.0',)
```

Or in Node.js using [better-sqlite3](https://github.com/WiseLibs/better-sqlite3):

```javascript
const Database = require("better-sqlite3");
const db = new Database(":memory:");
db.loadExtension("./ulid0");
console.log(db.prepare("select ulid_version()").get());
// { 'ulid_version()': 'v0.1.0' }
```

With [Datasette](https://datasette.io/), you should prefer the [`datasette-sqlite-ulid` Datasette plugin](./python/datasette_sqlite_ulid/README.md). However, you can manually load a pre-compiled extension into a Datasette instance like so:

```
datasette data.db --load-extension ./ulid0
```

## Supporting

I (Alex 👋🏼) spent a lot of time and energy on this project and [many other open source projects](https://github.com/asg017?tab=repositories&q=&type=&language=&sort=stargazers). If your company or organization uses this library (or you're feeling generous), then please [consider supporting my work](https://alexgarcia.ulid/work.html), or share this project with a friend!

## See also

- [sqlite-xsv](https://github.com/asg017/sqlite-xsv), A SQLite extension for working with CSVs
- [sqlite-loadable](https://github.com/asg017/sqlite-loadable-rs), A framework for writing SQLite extensions in Rust
- [sqlite-http](https://github.com/asg017/sqlite-http), A SQLite extension for making HTTP requests
