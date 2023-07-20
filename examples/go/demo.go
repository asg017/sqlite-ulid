package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/asg017/sqlite-ulid/bindings/go"
	_ "github.com/mattn/go-sqlite3"
)

// #cgo darwin,amd64 LDFLAGS: -framework CoreFoundation
// #cgo windows,amd64 LDFLAGS: -ladvapi32 -lbcrypt -lkernel32 -lmsvcrt -lntdll -luserenv -lws2_32
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
