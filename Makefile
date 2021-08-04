CC = clang
TOOL_SOURCES := tool/pubspec.lock $(shell find tool -name '*.dart')
BUILD_DIR := build
BUILD_SNAPSHOT := $(BUILD_DIR)/build.dart.snapshot
TEST_SNAPSHOT := $(BUILD_DIR)/test.dart.snapshot

default: clox

# Run dart pub get on tool directory
get: 
	@ cd ./tool; dart pub get

# Remove all build outputs and intermediate files
clean:
	@ rm -rf $(BUILD_DIR)

# Compiule a debug build of clox
debug:
	@ $(MAKE) -f ./c.make NAME=cloxd MODE=debug SOURCE_DIR=src

# Compile the C interpreter
clox:
	 @ $(MAKE) -f ./c.make NAME=clox MODE=release SOURCE_DIR=src
	 @ cp build/clox clox

# Compile the C interpreter as ANSI standard C++
cpplox:
	@ $(MAKE) -f ./c.make NAME=cpplox MODE=debud CPP=true SOURCE_DIR=src

$(BUILD_SNAPSHOT): $(TOOL_SOURCES)
	@ mkdir -p build
	@ echo "Compiling Dart snapshot..."
	@ dart --snapshot=$@ --snapshot-kind=app-jit tool/bin/build.dart > /dev/null

$(TEST_SNAPSHOT): $(TOOL_SOURCES)
	@ mkdir -p build
	@ echo "Compiling Dart snapshot..."
	@ dart --snapshot=$@ --snapshot-kind=app-jit tool/bin/test.dart clox > /dev/null

# Test clox
test: debug $(TEST_SNAPSHOT)
	@ dart $(TEST_SNAPSHOT) clox

# Linting stuff 
format:
	find . -type f -name "*.[c|h]" | xargs clang-format -i

check: src/*
	clang-tidy -checks=* --warnings-as-errors=* src/* > lint.log 2>&1

.PHONY: check clean clox debug format get test 
