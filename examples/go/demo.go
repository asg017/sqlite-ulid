package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/asg017/sqlite-ulid/bindings/go"
	_ "github.com/mattn/go-sqlite3"
)

// #cgo LDFLAGS: -L../../dist/debug
import "C"

func main() {
	db, err := sql.Open("sqlite3", ":memory:")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	var hello string
	var hola string
	err = db.QueryRow("select hello('alex'), hola('alex')").Scan(&hello, &hola)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("hello result: %s\n", hello)
	fmt.Printf("hola result: %s\n", hola)
}
