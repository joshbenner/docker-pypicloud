# joshbenner/pypicloud

Dockerfile to build a docker image for running a
[pypicloud](http://pypicloud.readthedocs.io/en/latest/) instance.

# Configuration

Configuration is provided via runtime environment variables.

| Env Var | Default | Description |
| ------- | ------- | ----------- |
| `PYPI_ADMIN_PASSWORD` | secret (encrypted) | The encrypted password to use for the admin user if using `config` auth method. This must be the encrypted form. See [below](#generating-passwords). |
| `PYPI_DB_URL` | sqlite:////var/lib/pypicloud/db.sqlite | The DB connection URL for the local metadata cache. |
| `PYPI_AUTH_DB_URL` | sqlite:////var//lib/pypicloud/db.sqlite | The DB connection URL for the auth DB if `PYPI_AUTH`=`sql` |
| `PYPI_SESSION_ENCRYPT_KEY` | replaceme | Key to use when encryption session data. |
| `PYPI_SESSION_VALIDATE_KEY` | replaceme | Key used to validate session data. |
| `PYPI_FALLBACK` | redirect | Behavior when package is not found in DB. Options: `redirect`, `cache`, `none` ([docs](http://pypicloud.readthedocs.io/en/latest/topics/configuration.html#pypi-fallback)) |
| `PYPI_FALLBACK_URL` | https://pypi.python.org/simple | The URL of another package index fro which to fetch packages when falling back. |
| `PYPI_STORAGE` | file | The package storage strategy. Options: `file`, `s3`, `cloudfront` ([docs](http://pypicloud.readthedocs.io/en/latest/topics/storage.html)) |
| `PYPI_STORAGE_DIR` | /var/lib/pypicloud/packages | Where to store packages when using the `file` option for `PYPI_STORAGE` variable. |
| `PYPI_STORAGE_BUCKET` | changeme | The S3 bucket to store packages when using the `s3` option for `PYPI_STORAGE` variable. |
| `AWS_ACCESS_KEY_ID` | changeme | The AWS access key ID to use when accessing an s3 bucket. |
| `AWS_SECRET_ACCESS_KEY` | changeme | The AWS secret access key to use when accessing an S3 bucket. |
| `PYPI_AUTH` | config | The authentication mode to use. Options: `config`, `sql`, `remote`, `ldap` ([docs](http://pypicloud.readthedocs.io/en/latest/topics/access_control.html)) |
| `PYPI_DEFAULT_READ` | authenticated | List of groups allowed to read packages that don't have explicit restrictions. |
| `PYPI_CACHE_UPDATE` | authenticated | List of groups allowed to update the package cache. |
| `PYPI_HTTP` | 0.0.0.0:8080 | The interface and port to bind to. ([docs](http://uwsgi-docs.readthedocs.io/en/latest/HTTP.html)) |
| `PYPI_PROCESSES` | 20 | The number of concurrent worker processes to run. |
| `PYPI_SSL_KEY` | (none) | Container path to the SSL private key if terminating SSL at the container. |
| `PYPI_SSL_CRT` | (none) | Container path to the SSL certificate if terminating SSL at the container. |

## Generating Passwords

```shell
$ docker run --rm -it joshbenner/pypicloud gen-password
```

Enter the password twice. An encrypted value will be printed that can be put in
the `PYPI_ADMIN_PASSWORD` environment variable. It will look something like:

    $6$rounds=704055$kq8HTiZC50zoffwq$T335/H9UxRegwAxcuTUggt.ip2CBpP18wTxOAGpK8DLBZ3jC2yVklFQxRtOd5tHqmzaxDIuq0VUJb/lzaLhNW0

## SSL Termination

Terminating SSL at a proxy or load balancer is recommended. However, SSL options
are available if you require SSL termination at the container:

```
PYPI_SSL_KEY=/certs/mysite.key
PYPI_SSL_CRT=/certs/mysite.crt
```

These paths must be available to the application running inside the container at
runtime.

## LDAP Authentication

LDAP authentication can be enabled by setting `PYPI_AUTH` to `ldap`, as well as
configuring the following additional LDAP-specific options:

| Env Var | Default | Description |
| ------- | ------- | ----------- |
| `PYPI_LDAP_URL` | | The LDAP connection URL. Example: `ldap://ldap.example.com:389` |
| `PYPI_LDAP_SERVICE_DN` | | The DN used to bind to LDAP. Requires read access to directory. Example: `cn=SuperUser,dc=example,dc=com` |
| `PYPI_LDAP_SERVICE_PASSWORD` | | The password used to bind to the service DN. |
| `PYPI_LDAP_BASEDN` | | The DN under which all users are found. Base of search in `PYPI_LDAP_USERSEARCH` |
| `PYPI_LDAP_USERSEARCH` | | The LDAP search that will find all potential users. Only searches under `PYPI_LDAP_BASEDN`. |
| `PYPI_LDAP_IDFIELD` | | The LDAP field that has the user name. |
| `PYPI_LDAP_ADMIN_DNS` | | Space-separated list of DNs that have a field listing user DNs to be considered admins. |
| `PYPI_LDAP_ADMIN_FIELD` | | The field in the DNs in `PYPI_LDAP_ADMIN_DNS` that identifies admin user DNs. |
