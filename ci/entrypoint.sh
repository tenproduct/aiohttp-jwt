#!/usr/bin/env bash

set -xeuo pipefail

# Run quality checks once under the default Python.
flake8 --show-source aiohttp_jwt tests
isort --check aiohttp_jwt tests

# Run tests across all installed Python versions.
# Coverage is generated from the first (lowest) version for SonarCloud.
FIRST=true
for PYENV_VERSION in $(ls /root/.pyenv/versions | sort); do
    MAJOR_MINOR=$(echo "${PYENV_VERSION}" | cut -d. -f1,2)
    if [ "${FIRST}" = "true" ]; then
        /bin/bash -l -c "python${MAJOR_MINOR} -m pytest --cov=aiohttp_jwt --cov-report=xml --cov-report=html tests/"
        FIRST=false
    else
        /bin/bash -l -c "python${MAJOR_MINOR} -m pytest tests/"
    fi
done
