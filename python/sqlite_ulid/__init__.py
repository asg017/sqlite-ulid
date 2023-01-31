import os
import sqlite3
import platform 

system = platform.system()

_extension_name = None
if system == 'Darwin':
  _extension_name = "ulid.dylib"
elif system == 'Windows':
  _extension_name = "ulid.dll"
else: 
  _extension_name = "ulid.so"

def loadable_path():
  loadable_path = os.path.join(os.path.dirname(__file__), _extension_name)
  return os.path.normpath(loadable_path)

def load(conn: sqlite3.Connection)  -> None:
  conn.load_extension(loadable_path())
