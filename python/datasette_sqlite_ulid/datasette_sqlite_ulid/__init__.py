from datasette import hookimpl
import sqlite_ulid

@hookimpl
def prepare_connection(conn):
    conn.enable_load_extension(True)
    sqlite_ulid.load(conn)
    conn.enable_load_extension(False)