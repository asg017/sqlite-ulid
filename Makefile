
ifeq ($(shell uname -s),Darwin)
CONFIG_DARWIN=y
else ifeq ($(OS),Windows_NT)
CONFIG_WINDOWS=y
else
CONFIG_LINUX=y
endif

LIBRARY_PREFIX=lib
ifdef CONFIG_DARWIN
LOADABLE_EXTENSION=dylib
endif

ifdef CONFIG_LINUX
LOADABLE_EXTENSION=so
endif


ifdef CONFIG_WINDOWS
LOADABLE_EXTENSION=dll
LIBRARY_PREFIX=
endif

prefix=dist
TARGET_LOADABLE=$(prefix)/debug/ulid0.$(LOADABLE_EXTENSION)
TARGET_LOADABLE_RELEASE=$(prefix)/release/ulid0.$(LOADABLE_EXTENSION)

TARGET_STATIC=$(prefix)/debug/ulid0.a
TARGET_STATIC_RELEASE=$(prefix)/release/ulid0.a

TARGET_WHEELS=$(prefix)/debug/wheels
TARGET_WHEELS_RELEASE=$(prefix)/release/wheels

INTERMEDIATE_PYPACKAGE_EXTENSION=python/sqlite_ulid/sqlite_ulid/ulid0.$(LOADABLE_EXTENSION)

ifdef target
CARGO_TARGET=--target=$(target)
BUILT_LOCATION=target/$(target)/debug/$(LIBRARY_PREFIX)sqlite_ulid.$(LOADABLE_EXTENSION)
BUILT_LOCATION_RELEASE=target/$(target)/release/$(LIBRARY_PREFIX)sqlite_ulid.$(LOADABLE_EXTENSION)
else 
CARGO_TARGET=
BUILT_LOCATION=target/debug/$(LIBRARY_PREFIX)sqlite_ulid.$(LOADABLE_EXTENSION)
BUILT_LOCATION_RELEASE=target/release/$(LIBRARY_PREFIX)sqlite_ulid.$(LOADABLE_EXTENSION)
endif

ifdef python
PYTHON=$(python)
else
PYTHON=python3
endif

ifdef IS_MACOS_ARM
RENAME_WHEELS_ARGS=--is-macos-arm
else
RENAME_WHEELS_ARGS=
endif

$(prefix):
	mkdir -p $(prefix)/debug
	mkdir -p $(prefix)/release

$(TARGET_WHEELS): $(prefix)
	mkdir -p $(TARGET_WHEELS)

$(TARGET_WHEELS_RELEASE): $(prefix)
	mkdir -p $(TARGET_WHEELS_RELEASE)

$(TARGET_LOADABLE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build $(CARGO_TARGET)
	cp $(BUILT_LOCATION) $@

$(TARGET_LOADABLE_RELEASE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build --release $(CARGO_TARGET)
	cp $(BUILT_LOCATION_RELEASE) $@

python: $(TARGET_WHEELS) $(TARGET_LOADABLE) python/sqlite_ulid/setup.py python/sqlite_ulid/sqlite_ulid/__init__.py .github/workflows/rename-wheels.py
	cp $(TARGET_LOADABLE) $(INTERMEDIATE_PYPACKAGE_EXTENSION) 
	rm $(TARGET_WHEELS)/sqlite_ulid* || true
	pip3 wheel python/sqlite_ulid/ -w $(TARGET_WHEELS)
	python3 .github/workflows/rename-wheels.py $(TARGET_WHEELS) $(RENAME_WHEELS_ARGS)

python-release: $(TARGET_LOADABLE_RELEASE) $(TARGET_WHEELS_RELEASE) python/sqlite_ulid/setup.py python/sqlite_ulid/sqlite_ulid/__init__.py .github/workflows/rename-wheels.py
	cp $(TARGET_LOADABLE_RELEASE)  $(INTERMEDIATE_PYPACKAGE_EXTENSION) 
	rm $(TARGET_WHEELS_RELEASE)/sqlite_ulid* || true
	pip3 wheel python/sqlite_ulid/ -w $(TARGET_WHEELS_RELEASE)
	python3 .github/workflows/rename-wheels.py $(TARGET_WHEELS_RELEASE) $(RENAME_WHEELS_ARGS)

datasette: $(TARGET_WHEELS) python/datasette_sqlite_ulid/setup.py python/datasette_sqlite_ulid/datasette_sqlite_ulid/__init__.py
	rm $(TARGET_WHEELS)/datasette* || true
	pip3 wheel python/datasette_sqlite_ulid/ --no-deps -w $(TARGET_WHEELS)

datasette-release: $(TARGET_WHEELS_RELEASE) python/datasette_sqlite_ulid/setup.py python/datasette_sqlite_ulid/datasette_sqlite_ulid/__init__.py
	rm $(TARGET_WHEELS_RELEASE)/datasette* || true
	pip3 wheel python/datasette_sqlite_ulid/ --no-deps -w $(TARGET_WHEELS_RELEASE)

format:
	cargo fmt

sqlite-ulid.h: cbindgen.toml
	rustup run nightly cbindgen  --config $< -o $@

release: $(TARGET_LOADABLE_RELEASE) $(TARGET_STATIC_RELEASE)

loadable: $(TARGET_LOADABLE)
loadable-release: $(TARGET_LOADABLE_RELEASE)

static: $(TARGET_STATIC)
static-release: $(TARGET_STATIC_RELEASE)

debug: loadable static python datasette
release: loadable-release static-release python-release datasette-release

clean:
	rm dist/*
	cargo clean

test-loadable:
	$(PYTHON) tests/test-loadable.py

test-python:
	$(PYTHON) tests/test-python.py

test:
	make test-loadable
	make test-python

.PHONY: clean \
	test test-loadable test-python \
	loadable loadable-release \
	python python-release \
	datasette datasette-release \
	static static-release \
	debug release