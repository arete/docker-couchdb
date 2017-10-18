FROM arete74/voidlinux

LABEL mantainer Gerardo Di Iorio arete74@gmail.com

RUN xbps-install -Syu runit shadow util-linux 
RUN xbps-reconfigure -f base-files

COPY ./couchdb1.6 /

RUN xbps-install -Sy --repository=./couchdb1.6 couchdb
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
VOLUME ["/var/lib/couchdb"]

EXPOSE 5984
WORKDIR /var/lib/couchdb

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["couchdb"]
