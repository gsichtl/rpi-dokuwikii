# REV 0.1
# AUTHOR:       David E
# DESCRIPTION:	Image with DokuWiki & lighttpd
# TO_BUILD:	docker build -t macus/dokuwikii
# TO_RUN:	docker run -d -p 80:80 --name my_wiki macus/rpi-dokuwikii
   
FROM resin/rpi-raspbian:jessie
MAINTAINER Macus

ENV DOKUWIKI_VERSION 2016-06-26a
ENV DOKUWIKI_CSUM 9b9ad79421a1bdad9c133e859140f3f2

ENV LAST_REFRESHED 26. September 2016

# Update & install packages & cleanup afterwards
RUN apt-get update && apt-get -y install wget lighttpd php5-cgi php5-gd php5-ldap && apt-get -y clean

# Download & check & deploy dokuwiki & cleanup
RUN wget -q -O /dokuwiki.tgz "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
	if [ "$DOKUWIKI_CSUM" != "$(md5sum /dokuwiki.tgz | awk '{print($1)}')" ];then echo "Wrong md5sum of downloaded file!"; exit 1; fi && \
	mkdir /dokuwiki && \
	tar -zxf dokuwiki.tgz -C /dokuwiki --strip-components 1 && \
	rm dokuwiki.tgz

# Set up ownership
RUN chown -R www-data:www-data /dokuwiki

# Configure lighttpd
ADD dokuwiki.conf /etc/lighttpd/conf-available/20-dokuwiki.conf
RUN lighty-enable-mod dokuwiki fastcgi accesslog
RUN mkdir /var/run/lighttpd && chown www-data.www-data /var/run/lighttpd

EXPOSE 80

VOLUME ["/dokuwiki/data/","/dokuwiki/lib/plugins/","/dokuwiki/conf/","/dokuwiki/lib/tpl/","/var/log/"]
ENTRYPOINT ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]
