#!/bin/bash
set -e

/usr/local/bin/confd -onetime -backend env

if [ "$1" == "pypi" ]; then
	exec uwsgi /config.ini
elif [ "$1" == "make-config" ]; then
	exec ppc-make-config ${1--r}
elif [ "$1" == "gen-password" ]; then
	exec ppc-gen-password ${1--r}
fi

exec "$@"
