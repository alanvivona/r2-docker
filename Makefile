OS ?= 'ubuntu'
ARCH ?= 'amd64'
VERSION ?= 'latest'
R2_VERSION ?= 'master'
R2_TAG ?= 5.9.8
work_dir ?= $(shell pwd)

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Common way for images building, can be used variables: R2_VERSION ('master'), R2_TAG (5.9.8)
	docker build -t luckycatalex/r2-frida:${R2_TAG} \
	--build-arg R2_VERSION=${R2_VERSION} --build-arg R2_TAG=${R2_TAG} \
	--network=host . -f Dockerfile

run: ## Common way for images runnig, can be used variables: R2_TAG (5.9.8), work_dir (current directory...)
	sh -c "docker run --network=host --rm -v $(work_dir):/work_dir \
	-it luckycatalex/r2-frida:${R2_TAG}" /usr/bin/bash; echo "Exit from container"