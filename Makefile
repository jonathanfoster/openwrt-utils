SHELL=/bin/bash
VERSION=1.0.0

all: lint

.PHONY: install
install:
	./scripts/install.sh

.PHONY: lint
lint:
	shellcheck ./**/*.sh
