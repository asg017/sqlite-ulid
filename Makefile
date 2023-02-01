
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
TARGET_STATIC=$(prefix)/debug/ulid0.a

TARGET_LOADABLE_RELEASE=$(prefix)/release/ulid0.$(LOADABLE_EXTENSION)
TARGET_STATIC_RELEASE=$(prefix)/release/ulid0.a

TARGET_PYPACKAGE=$(prefix)/debug/wheelhouse

INTERMEDIATE_PYPACKAGE_EXTENSION=python/sqlite_ulid/ulid0.$(LOADABLE_EXTENSION)

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

$(prefix):
	mkdir -p $(prefix)/debug
	mkdir -p $(prefix)/release

$(TARGET_LOADABLE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build $(CARGO_TARGET)
	cp $(BUILT_LOCATION) $@

$(TARGET_LOADABLE_RELEASE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build --release $(CARGO_TARGET)
	cp $(BUILT_LOCATION_RELEASE) $@


$(INTERMEDIATE_PYPACKAGE_EXTENSION): $(TARGET_LOADABLE)
	cp $(TARGET_LOADABLE) $(INTERMEDIATE_PYPACKAGE_EXTENSION)
	
$(TARGET_PYPACKAGE): $(INTERMEDIATE_PYPACKAGE_EXTENSION) python/setup.py python/sqlite_ulid/__init__.py .github/workflows/rename-wheels.py
	rm $(TARGET_PYPACKAGE)/* || true
	pip wheel python/ -w $(TARGET_PYPACKAGE)
	python3 .github/workflows/rename-wheels.py $(TARGET_PYPACKAGE)
	touch $(TARGET_PYPACKAGE)

format:
	cargo fmt

sqlite-ulid.h: cbindgen.toml
	rustup run nightly cbindgen  --config $< -o $@

release: $(TARGET_LOADABLE_RELEASE) $(TARGET_STATIC_RELEASE)

loadable: $(TARGET_LOADABLE)
loadable-release: $(TARGET_LOADABLE_RELEASE)
static: $(TARGET_STATIC)
python: $(TARGET_PYPACKAGE)
debug: loadable static

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

.PHONY: clean test loadable static debug