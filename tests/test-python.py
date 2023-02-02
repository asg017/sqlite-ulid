import unittest
import sqlite3
import sqlite_ulid

class TestSqliteUlidPython(unittest.TestCase):
  def test_path(self):
    db = sqlite3.connect(':memory:')
    db.enable_load_extension(True)

    self.assertEqual(type(sqlite_ulid.loadable_path()), str)
    
    sqlite_ulid.load(db)
    version, ulid = db.execute('select ulid_version(), ulid()').fetchone()
    self.assertEqual(version[0], "v")
    self.assertEqual(len(ulid), 26)

if __name__ == '__main__':
    unittest.main()