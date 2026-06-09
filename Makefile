# Makefile for realdate

PREFIX ?= /usr/local
INSTALL_PATH = $(PREFIX)/bin
BINARY_NAME = realdate
BUILD_PATH = .build/release/$(BINARY_NAME)

.PHONY: build install uninstall clean

build:
	@echo "Building realdate..."
	swift build -c release

install: build
	@echo "Installing realdate to $(INSTALL_PATH)..."
	@install -d $(INSTALL_PATH)
	@install -m 755 $(BUILD_PATH) $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✓ realdate installed to $(INSTALL_PATH)/$(BINARY_NAME)"

uninstall:
	@echo "Uninstalling realdate from $(INSTALL_PATH)..."
	@rm -f $(INSTALL_PATH)/$(BINARY_NAME)
	@echo "✓ realdate uninstalled"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@echo "✓ Build artifacts removed"
