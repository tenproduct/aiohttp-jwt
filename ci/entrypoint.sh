#!/usr/bin/env bash

set -xeuo pipefail

pip install -e .
flake8 --show-source aiohttp_jwt
isort --check-only -rc aiohttp_jwt --diff
flake8 --show-source setup.py
isort --check-only setup.py --diff
flake8 --show-source tests
isort --check-only -rc tests --diff
pytest --cov=./aiohttp_jwt tests/
