FROM python:2.7-alpine

# Default credentials: admin/secret
# Use ppc-gen-password to generate new value.
ENV PYPICLOUD_VERSION=0.4.0 \
    CONFD_VERSION=0.12.0-alpha3 \
    PYPI_ADMIN_PASSWORD='$6$rounds=704055$kq8HTiZC50zoffwq$T335/H9UxRegwAxcuTUggt.ip2CBpP18wTxOAGpK8DLBZ3jC2yVklFQxRtOd5tHqmzaxDIuq0VUJb/lzaLhNW0' \
    PYPI_DB_URL=sqlite:////var/lib/pypicloud/db.sqlite \
    PYPI_AUTH_DB_URL=sqlite:////var/lib/pypicloud/db.sqlite \
    PYPI_SESSION_ENCRYPT_KEY=replaceme \
    PYPI_SESSION_VALIDATE_KEY=replaceme \
    PYPI_SESSION_SECURE=false \
    PYPI_FALLBACK=redirect \
    PYPI_FALLBACK_URL=https://pypi.python.org/simple \
    PYPI_STORAGE=file \
    PYPI_STORAGE_DIR=/var/lib/pypicloud/packages \
    PYPI_STORAGE_BUCKET=changeme \
    AWS_ACCESS_KEY_ID=changeme \
    AWS_SECRET_ACCESS_KEY=changeme \
    PYPI_AUTH=config \
    PYPI_DEFAULT_READ=authenticated \
    PYPI_CACHE_UPDATE=authenticated \
    PYPI_HTTP=0.0.0.0:8080 \
    PYPI_PROCESSES=20 \
    PYPI_SSL_KEY= \
    PYPI_SSL_CRT=

# Installing uwsgi and pypicloud in same pip command fails for some reason.
RUN apk --no-cache add --virtual .build-deps build-base linux-headers \
    && pip install --no-cache-dir uwsgi \
    && pip install --no-cache-dir pypicloud==$PYPICLOUD_VERSION \
    && mkdir -p /etc/confd/conf.d /etc/confd/templates /var/lib/pypicloud/packages \
    && apk del .build-deps

COPY config.ini.tmpl /etc/confd/templates/config.ini.tmpl
COPY config.ini.toml /etc/confd/conf.d/config.ini.toml

ADD https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd

EXPOSE 8080

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["pypi"]