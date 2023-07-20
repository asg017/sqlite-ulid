package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/asg017/sqlite-ulid/bindings/go"
	_ "github.com/mattn/go-sqlite3"
)

// #cgo darwin,amd64 LDFLAGS: -framework CoreFoundation
// #cgo windows LDFLAGS: -lbcrypt -ladvapi32 -lkernel32 -ladvapi32 -ladvapi32 -lbcrypt -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lkernel32 -lntdll -lntdll -lntdll -lntdll -luserenv -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lws2_32 -lkernel32 -lkernel32
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
