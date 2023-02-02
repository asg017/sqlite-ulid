# The `datasette-sqlite-ulid` Datasette Plugin

`datasette-sqlite-ulid` is a [Datasette plugin](https://docs.datasette.io/en/stable/plugins.html) that loads the [`sqlite-ulid`](https://github.com/asg017/sqlite-ulid) extension in Datasette instances, allowing you to generate and work with [ULIDs](https://github.com/ulid/spec) in SQL.

```
datasette install datasette-sqlite-ulid
```

See [`docs.md`](../../docs.md) for a full API reference for the ULID SQL functions.

Alternatively, when publishing Datasette instances, you can use the `--install` option to install the plugin.

```
datasette publish cloudrun data.db --service=my-service --install=datasette-sqlite-ulid

```
