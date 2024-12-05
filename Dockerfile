FROM httpd:2.4

COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf

RUN mkdir -p /data/www  /usr/local/apache2/logs \
  && chmod -R 777 /data/www  /usr/local/apache2/logs

