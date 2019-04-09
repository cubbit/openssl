.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

development: ## Run the development environment
	docker build -t openssl:dev .
	docker run -it --rm --name openssl_dev --rm -v $(shell pwd):/usr/src/openssl openssl:dev
