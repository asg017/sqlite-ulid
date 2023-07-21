#include "sqlite3.h"
#include "sqlite-ulid.h"
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int rc = SQLITE_OK;
  sqlite3 *db;
  sqlite3_stmt *stmt;
  char* error_message;

  rc = sqlite3_auto_extension((void (*)())sqlite3_ulid_init);
  if (rc != SQLITE_OK) {
    fprintf(stderr, "❌ demo.c could not load sqlite3_ulid_init: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    return 1;
  }

  rc = sqlite3_open(":memory:", &db);

  if (rc != SQLITE_OK) {
    fprintf(stderr, "❌ demo.c cannot open database: %s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    return 1;
  }

  rc = sqlite3_prepare_v2(db, "SELECT ulid()", -1, &stmt, NULL);
  if(rc != SQLITE_OK) {
    fprintf(stderr, "❌ demo.c%s\n", error_message);
    sqlite3_free(error_message);
    sqlite3_close(db);
    return 1;
  }
  if (SQLITE_ROW != sqlite3_step(stmt)) {
    fprintf(stderr, "❌ demo.c%s\n", sqlite3_errmsg(db));
    sqlite3_close(db);
    return 1;
  }
  printf("ulid()=%s\n", sqlite3_column_text(stmt, 0));
  sqlite3_finalize(stmt);

  printf("✅ demo.c ran successfully. \n");
  sqlite3_close(db);
  return 0;
}
