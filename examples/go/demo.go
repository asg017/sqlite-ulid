package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/asg017/sqlite-ulid/bindings/go"
	_ "github.com/mattn/go-sqlite3"
)

// #cgo darwin,amd64 LDFLAGS: -framework CoreFoundation
// #cgo windows,amd64 CFLAGS:  -IC:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\x86_64-w64-mingw32\include
// #cgo windows,amd64 LDFLAGS:  -LC:\ProgramData\chocolatey\lib\mingw\tools\install\mingw64\x86_64-w64-mingw32\lib -lwinapi_advapi32 -lwinapi_kernel32 -lbcrypt -ladvapi32 -lkernel32 -ladvapi32 -luserenv -lkernel32 -lkernel32 -lws2_32 -lbcrypt
import "C"

func main() {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	var ulid string
	err = db.QueryRow("select ulid()").Scan(&ulid)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("ulid: %s\n", ulid)
}
