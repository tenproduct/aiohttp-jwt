FROM 133824686826.dkr.ecr.eu-west-1.amazonaws.com/docker-hub/library/debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
WORKDIR /var/aiohttp-jwt/
ARG PYTHON_VERSIONS="3.10 3.11 3.12"

# Install dependencies and pyenv.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncurses5-dev \
    xz-utils \
    libxml2-dev \
    git \
    ca-certificates \
    libffi-dev \
    liblzma-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /var/cache/apt/archives/*.deb \
    && git clone https://github.com/pyenv/pyenv /root/.pyenv

# Install the desired versions of Python.
RUN for PYTHON_VERSION in ${PYTHON_VERSIONS}; do \
    set -ex \
    && /root/.pyenv/bin/pyenv install ${PYTHON_VERSION} \
    ; done

# Add Python versions to PATH.
RUN for PYTHON_VERSION in $(ls /root/.pyenv/versions); do \
    set -ex \
    && PYENV_BIN_PATH="/root/.pyenv/versions/${PYTHON_VERSION}/bin" \
    && echo 'export PATH="'${PYENV_BIN_PATH}':$PATH"' >> /root/.bash_profile \
    ; done

# Set the default Python version (first in list).
RUN set -ex \
    && FIRST_VERSION=$(echo ${PYTHON_VERSIONS} | awk '{print $1}' | cut -d. -f1,2) \
    && echo "alias python=python${FIRST_VERSION}" >> /root/.bash_profile \
    && ln -sf $(find /root/.pyenv/versions -name "python${FIRST_VERSION}" -type f | head -1) /usr/local/bin/python

# Upgrade pip and install setuptools for all Python versions.
RUN for PYTHON_VERSION in ${PYTHON_VERSIONS}; do \
    set -ex \
    && MAJOR_MINOR=$(echo ${PYTHON_VERSION} | cut -d. -f1,2) \
    && /bin/bash -l -c "python${MAJOR_MINOR} -m pip install --upgrade pip 'setuptools>=78.1.1'" \
    ; done

# Copy dependencies.
COPY pyproject.toml poetry.lock ./

# Install Poetry and export requirements.
RUN /bin/bash -l -c "python -m pip install poetry==1.4.* \
    && poetry export --with dev --without-hashes --format=requirements.txt > requirements.txt"

# Install dependencies for all Python versions.
RUN for PYTHON_VERSION in ${PYTHON_VERSIONS}; do \
    set -ex \
    && MAJOR_MINOR=$(echo ${PYTHON_VERSION} | cut -d. -f1,2) \
    && /bin/bash -l -c "python${MAJOR_MINOR} -m pip install -r requirements.txt" \
    ; done

# Copy source files.
COPY . /var/aiohttp-jwt/

RUN ["chmod", "+x", "./ci/entrypoint.sh"]
ENTRYPOINT ["/bin/bash", "-l", "-c", "./ci/entrypoint.sh"]
