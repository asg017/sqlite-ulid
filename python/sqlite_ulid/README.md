# The `sqlite-ulid` Python package

`sqlite-ulid` is also distributed on PyPi as a Python package, for use in Python applications. It works well with the builtin [`sqlite3`](https://docs.python.org/3/library/sqlite3.html) Python module.

```
pip install sqlite-ulid
```

## Usage

The `sqlite-ulid` python package exports two functions: `loadable_path()`, which returns the full path to the loadable extension, and `load(conn)`, which loads the `sqlite-ulid` extension into the given [sqlite3 Connection object](https://docs.python.org/3/library/sqlite3.html#connection-objects).

```python
import sqlite_ulid
print(sqlite_ulid.loadable_path())
# '/.../venv/lib/python3.9/site-packages/sqlite_ulid/ulid0'

import sqlite3
conn = sqlite3.connect(':memory:')
sqlite_ulid.load(conn)
conn.execute('select ulid_version(), ulid()').fetchone()
# ('v0.1.0', '01gr7gwc5aq22ycea6j8kxq4s9')
```

See [the full API Reference](#api-reference) for the Python API, and [`docs.md`](../../docs.md) for documentation on the `sqlite-ulid` SQL API.

See [`datasette-sqlite-ulid`](../datasette_sqlite_ulid/) for a Datasette plugin that is a light wrapper around the `sqlite-ulid` Python package.

## Compatibility

Currently the `sqlite-ulid` Python package is only distributed on PyPi as pre-build wheels, it's not possible to install from the source distribution. This is because the underlying `sqlite-ulid` extension requires a lot of build dependencies like `make`, `cc`, and `cargo`.

If you get a `unsupported platform` error when pip installing `sqlite-ulid`, you'll have to build the `sqlite-ulid` manually and load in the dynamic library manually.

## API Reference

<h3 name="loadable_path"><code>loadable_path()</code></h3>

Returns the full path to the locally-install `sqlite-ulid` extension, without the filename.

This can be directly passed to [`sqlite3.Connection.load_extension()`](https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection.load_extension), but the [`sqlite_ulid.load()`](#load) function is preferred.

```python
import sqlite_ulid
print(sqlite_ulid.loadable_path())
# '/.../venv/lib/python3.9/site-packages/sqlite_ulid/ulid0'
```

> Note: this extension path doesn't include the file extension (`.dylib`, `.so`, `.dll`). This is because [SQLite will infer the correct extension](https://www.sqlite.org/loadext.html#loading_an_extension).

<h3 name="load"><code>load(connection)</code></h3>

Loads the `sqlite-ulid` extension on the given [`sqlite3.Connection`](https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection) object, calling [`Connection.load_extension()`](https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection.load_extension).

```python
import sqlite_ulid
import sqlite3
conn = sqlite3.connect(':memory:')

conn.enable_load_extension(True)
sqlite_ulid.load(conn)
conn.enable_load_extension(False)

conn.execute('select ulid_version(), ulid()').fetchone()
# ('v0.1.0', '01gr7gwc5aq22ycea6j8kxq4s9')
```
