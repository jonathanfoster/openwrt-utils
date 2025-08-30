SHELL=/bin/bash
VERSION=1.0.0

.DEFAULT_GOAL:=help

.PHONY: fmt
fmt: fmt-markdown fmt-shell ## Check all files formatting

.PHONY: fmt-fix
fmt-fix: fmt-markdown-fix fmt-shell-fix ## Fix all files formatting

.PHONY: fmt-markdown
fmt-markdown: ## Check Markdown files formatting
	@echo "Checking Markdown files formatting"
	prettier -c **/*.md

.PHONY: fmt-markdown-fix
fmt-markdown-fix: ## Fix Markdown files formatting
	@echo "Fixing Markdown files formatting"
	prettier -w **/*.md

.PHONY: fmt-shell
fmt-shell: ## Check shell scripts formatting
	@echo "Checking shell scripts formatting"
	shfmt -l -d .

.PHONY: fmt-shell-fix
fmt-shell-fix: ## Fix shell scripts formatting
	@echo "Fixing shell scripts formatting"
	shfmt -l -w .

.PHONY: help
help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available Targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install-deps
install-deps: ## Install dependencies for current OS
	@echo "Installing dependencies"
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) install-deps-macos; \
	else \
		echo "error: unsupported operating system: $$(uname)"; \
		exit 1; \
	fi

.PHONY: install-deps-macos
install-deps-macos: ## Install dependencies for MacOS
	@echo "Installing dependencies for MacOS"
	@if ! command -v brew &> /dev/null; then \
		echo "error: brew is not installed" 1>&2; \
		exit 1; \
	fi
	brew update
	brew install markdownlint-cli
	brew install prettier
	brew install shellcheck
	brew install shfmt

.PHONY: install
install:
	./scripts/install.sh

.PHONY: lint
lint: lint-markdown lint-shell ## Run all linters

.PHONY: lint-markdown
lint-markdown: ## Lint Markdown files
	@echo "Linting Markdown files"
	markdownlint -d '**/*.md'

.PHONY: lint-shell
lint-shell: ## Lint shell scripts
	@echo "Linting shell scripts"
	find . -type f -name "*.sh" | xargs shellcheck

.PHONY: pre-commit
pre-commit: fmt lint ## Run pre-commit hooks
