CGO_LDFLAGS="-L$(SQLITE_ULID_LIB_DIR)"

demo: demo.go
	CGO_LDFLAGS=$(CGO_LDFLAGS) go build -o $@


ifndef SQLITE_ULID_LIB_DIR
	$(error SQLITE_ULID_LIB_DIR is undefined)
endif
