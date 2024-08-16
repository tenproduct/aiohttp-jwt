#
# Makefile for aiohttp-jwt
#

include ./make/print.lib.mk

#------------------------------
# vars
#------------------------------

SHELL := /bin/bash
PWD:=$(shell pwd)

#------------------------------
# help
#------------------------------

.PHONY: help
help:
	$(call print_h1,"AVAILABLE","OPTIONS")
	$(call print_space)
	$(call print_h2,"docker")
	$(call print_options,"build","Build docker images for development.")
	$(call print_space)
	$(call print_h2,"dependency")
	$(call print_options,"pip-compile-rsa","Compile requirements.txt from requirements.in without upgrading the packages. (For users with SSH key built using RSA algorithm)")
	$(call print_options,"pip-compile-ed-25519","Compile requirements.txt from requirements.in without upgrading the packages. (For users with SSH key built using Ed25519 algorithm)")
	$(call print_space)
	$(call print_h2,"test")
	$(call print_options,"test","Run all tests.")
	$(call print_space)
	$(call print_h2,"code")
	$(call print_options,"lint","Run code lint checks.")
	$(call print_options,"format","Automatically format code where possible.")

#------------------------------
# docker
#------------------------------

.PHONY: build
build:
	$(call print_h1,"BUILDING","IMAGES")
	@docker build --ssh default -t tenproduct/aiohttp_jwt_3_9 --build-arg python_version=3.9 .
	@docker-compose build --parallel
	$(call print_h1,"IMAGES","BUILT")


.PHONY: build-python-3.9
build-python-3.9:
	$(call print_h1,"BUILDING","PYTHON","3.9","IMAGE")
	@docker build --ssh default -t tenproduct/aiohttp_jwt_3_9 .
	@docker-compose build aiohttp_jwt_3_9
	$(call print_h1,"PYTHON","3.9","IMAGE","BUILT")

#------------------------------
# dependency
#------------------------------

.PHONY: pip-compile-ed-25519
pip-compile-ed-25519: build-python-3.9
	$(call print_h1,"COMPILING","REQUIREMENTS","USING","ED25519")
	docker run --entrypoint= --rm --tty --interactive --env SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock  -v ~/.ssh/id_ed25519:/id_ed25519:ro -v ~/.ssh/id_ed25519.pub:/id_ed25519.pub:ro -v ${PWD}:/tenplatform/aiohttp-jwt tenproduct/aiohttp_jwt_3_9 sh -c "ssh-add /id_ed25519 && pip-compile --no-header --output-file=requirements.txt"
	$(call print_h1,"REQUIREMENTS","COMPILED")

.PHONY: pip-compile-rsa
pip-compile-rsa: build-python-3.9
	$(call print_h1,"COMPILING","REQUIREMENTS","USING","RSA")
	docker run --entrypoint= --rm --tty --interactive --env SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock  -v ~/.ssh/id_rsa:/id_rsa:ro -v ~/.ssh/id_rsa.pub:/id_rsa.pub:ro -v ${PWD}:/tenplatform/aiohttp-jwt tenproduct/aiohttp_jwt_3_9 sh -c "ssh-add /id_rsa && pip-compile --no-header --output-file=requirements.txt"
	$(call print_h1,"REQUIREMENTS","COMPILED")

#------------------------------
# code
#------------------------------

.PHONY: lint
lint: build-python-3.9
	$(call print_h1,"LINTING","CODE")
	@docker-compose run --rm --entrypoint= aiohttp_jwt_3_9 flake8 .
	@docker-compose run --rm --entrypoint= aiohttp_jwt_3_9 isort --check-only -rc aiohttp_jwt setup.py tests --diff
	$(call print_h1,"LINTING","COMPLETED")

.PHONY: format
format: build-python-3.9
	$(call print_h1,"FORMATTING","CODE")
	@docker-compose run --rm --entrypoint= aiohttp_jwt_3_9 isort -rc aiohttp_jwt setup.py tests
	$(call print_h1,"FORMATTING","COMPLETED")

#------------------------------
# QA
#------------------------------

.PHONY: test
test: build-python-3.9
	$(call print_h1,"RUNNING","ALL","TESTS")
	@docker-compose run --rm --entrypoint= aiohttp_jwt_3_9 pytest tests/
	$(call print_h1,"ALL","TESTS","COMPLETED")
