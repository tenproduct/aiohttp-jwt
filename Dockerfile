ARG python_version
FROM python:${python_version:-3.8}-slim

ENV PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:$PATH

ENV DIRPATH=/tenplatform/aiohttp-jwt
WORKDIR $DIRPATH

RUN apt-get update && \
    apt-get -qy install \
    build-essential \
    ssh


RUN mkdir -pm 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

COPY requirements.txt $DIRPATH/

RUN --mount=type=ssh \
    python -m venv $VIRTUAL_ENV && \
    pip install --upgrade pip  && \
    pip install --upgrade pip-tools && \
    pip install -r requirements.txt && \
    rm -r /root/.cache

COPY . $DIRPATH/

RUN ["chmod", "+x", "./ci/entrypoint.sh"]
ENTRYPOINT ["./ci/entrypoint.sh"]
