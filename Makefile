# Makefile for the Hugo website

# Tools / variables (can be overridden on the command line)
HUGO ?= hugo
BIND ?= 0.0.0.0
SERVE_FLAGS ?= --cleanDestinationDir --bind=$(BIND)
HUGOFLAGS ?= --minify

.PHONY: help serve build clean lint-markdown lint-markdown-fix

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Common targets:"
	@echo "  serve            Start Hugo dev server (hugo serve --cleanDestinationDir)"
	@echo "  build            Build the site to ./public"
	@echo "  clean            Remove generated public files"
	@echo "  lint-markdown    Lint markdown files"
	@echo "  lint-markdown-fix Fix markdown files automatically"
	@echo "  help             Show this help"
	@echo
	@echo "Variables (can be overridden):"
	@echo "  HUGO=$(HUGO)"
	@echo "  PORT=$(PORT)"
	@echo "  BIND=$(BIND)"
	@echo "  BASEURL=$(BASEURL)"

up:
	which werf >/dev/null || source $(trdl use werf 2 beta)
	werf compose up --dev

serve:
	$(HUGO) serve $(SERVE_FLAGS)

build:
	@echo "Building site to ./public..."
	$(HUGO) $(HUGOFLAGS)

clean:
	@echo "Removing ./public/*"
	@rm -rf public/*

lint-markdown:
	@echo "Linting markdown files..."
	@docker run --rm -v "$(PWD):/workdir" -w /workdir ghcr.io/igorshubovych/markdownlint-cli:v0.45.0 "**/*.md" -c markdownlint.yaml

lint-markdown-fix:
	@echo "Fixing markdown files..."
	@docker run --rm -v "$(PWD):/workdir" -w /workdir ghcr.io/igorshubovych/markdownlint-cli:v0.45.0 "**/*.md" -c markdownlint.yaml --fix
