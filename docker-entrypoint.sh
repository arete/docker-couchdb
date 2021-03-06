#!/bin/bash

set -e

if [ "$1" = 'couchdb' ]; then
	# we need to set the permissions here because docker mounts volumes as root
	chown -R couchdb:couchdb \
		/var/lib/couchdb \
		/var/log/couchdb \
		/var/run/couchdb \
		//etc/couchdb

	chmod -R 0770 \
		/var/lib/couchdb \
		/var/log/couchdb \
		/var/run/couchdb \
		//etc/couchdb

	chmod 664 /etc/couchdb/*.ini
	chmod 775 /etc/couchdb/*.d

	if [ "$COUCHDB_USER" ] && [ "$COUCHDB_PASSWORD" ]; then
		# Create admin
		printf "[admins]\n%s = %s\n" "$COUCHDB_USER" "$COUCHDB_PASSWORD" > /usr/local/etc/couchdb/local.d/docker.ini
		chown couchdb:couchdb /etc/couchdb/local.d/docker.ini
	fi

	printf "[httpd]\nport = %s\nbind_address = %s\n" ${COUCHDB_HTTP_PORT:=5984} ${COUCHDB_HTTP_BIND_ADDRESS:=0.0.0.0} > /etc/couchdb/local.d/bind_address.ini
	chown couchdb:couchdb /etc/couchdb/local.d/bind_address.ini

	# if we don't find an [admins] section followed by a non-comment, display a warning
	if ! grep -Pzoqr '\[admins\]\n[^;]\w+' /etc/couchdb; then
		# The - option suppresses leading tabs but *not* spaces. :)
		cat >&2 <<-'EOWARN'
			****************************************************
			WARNING: CouchDB is running in Admin Party mode.
			         This will allow anyone with access to the
			         CouchDB port to access your database. In
			         Docker's default configuration, this is
			         effectively any other container on the same
			         system.
			         Use "-e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password"
			         to set it in "docker run".
			****************************************************
		EOWARN
	fi

	exec  chpst -u couchdb:couchdb couchdb -r 5 -o /dev/null  -e /dev/null  "$@"
fi

exec "$@"
