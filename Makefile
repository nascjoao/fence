VERSION = $(shell cat VERSION)
BUILD_DIR = build/fence
TAR_FILE = build/fence-$(VERSION).tar.gz

.PHONY: build clean test install release

build:
	@echo "📦 Generating distribution package..."
	rm -rf build
	mkdir -p $(BUILD_DIR)
	cp -r bin lib VERSION $(BUILD_DIR)
	@COPYFILE_DISABLE=1 tar --no-xattrs -czf $(TAR_FILE) -C build fence
	rm -rf $(BUILD_DIR)
	@echo "✅ File created: $(TAR_FILE)"

clean:
	rm -rf build

test:
	@echo "🧪 Running tests..."
	@./test/bats/bin/bats test

install:
	@sh install.sh

release:
	@sh release.sh
