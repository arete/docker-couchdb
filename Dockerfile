FROM arete74/voidlinux

LABEL mantainer Gerardo Di Iorio arete74@gmail.com

RUN xbps-install -Syu runit shadow 
COPY couchdb2.1 /repo
RUN xbps-install -R /repo -Syu couchdb

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
VOLUME ["/var/lib/couchdb"]

EXPOSE 5984
WORKDIR /var/lib/couchdb

ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
CMD ["couchdb"]
