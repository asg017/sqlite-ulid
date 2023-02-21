from datasette import hookimpl
import sqlite_ulid

from datasette_sqlite_ulid.version import __version_info__, __version__ 

@hookimpl
def prepare_connection(conn):
    conn.enable_load_extension(True)
    sqlite_ulid.load(conn)
    conn.enable_load_extension(False)