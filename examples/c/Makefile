#		-L/usr/local/opt/sqlite/lib
demo: demo.c
	gcc $< \
		-Os \
		$(CFLAGS) \
		-I../../dist/debug \
		-L../../dist/debug \
		-Wl,-undefined,dynamic_lookup \
		-lsqlite3 -lsqlite_ulid0 \
		-o $@
