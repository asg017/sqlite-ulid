from sqlite_ulid.version import __version_info__, __version__ 

import os
import sqlite3

def loadable_path():
  loadable_path = os.path.join(os.path.dirname(__file__), "ulid0")
  return os.path.normpath(loadable_path)

def load(conn: sqlite3.Connection)  -> None:
  conn.load_extension(loadable_path())
