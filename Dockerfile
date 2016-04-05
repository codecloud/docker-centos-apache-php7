FROM centos:latest

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install yum-utils && \
    yum-config-manager --enable remi-php70 && \
    yum update -y && \
    yum install -y \
    php70-php.x86_64 \
    php70-php-bcmath.x86_64 \
    php70-php-cli.x86_64 \
    php70-php-common.x86_64 \
    php70-php-devel.x86_64 \
    php70-php-gd.x86_64 \
    php70-php-intl.x86_64 \
    php70-php-json.x86_64 \
    php70-php-mbstring.x86_64 \
    php70-php-mcrypt.x86_64 \
    php70-php-pdo.x86_64 \
    php70-php-pear.noarch \
    php70-php-xml.x86_64 \
    php70-php-ast.x86_64 \
    php70-php-opcache.x86_64 \
    php70-php-pecl-memcached.x86_64 && \
    ln -s /usr/bin/php70 /usr/bin/php && \
    ln -s /etc/opt/remi/php70/php.ini /etc/php.ini && \
    ln -s /etc/opt/remi/php70/php.d /etc/php.d && \
    ln -s /etc/opt/remi/php70/pear.conf /etc/pear.conf && \
    ln -s /etc/opt/remi/php70/pear /etc/pear


RUN yum install -y httpd-devel.x86_64 nano wget memcached

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN usermod -u 1000 apache && ln -sf /dev/stdout /var/log/httpd/access_log && ln -sf /dev/stderr /var/log/httpd/error_log

RUN unlink /etc/localtime && ln -s /usr/share/zoneinfo/Europe/London /etc/localtime

RUN rm /etc/httpd/conf.d/welcome.conf \
    && sed -i -e "s/Options\ Indexes\ FollowSymLinks/Options\ -Indexes\ +FollowSymLinks/g" /etc/httpd/conf/httpd.conf \
    && sed -i "s/\/var\/www\/html/\/var\/www/g" /etc/httpd/conf/httpd.conf \
    && echo "FileETag None" >> /etc/httpd/conf/httpd.conf \
    && sed -i -e "s/expose_php\ =\ On/expose_php\ =\ Off/g" /etc/php.ini \
    && sed -i -e "s/\;error_log\ =\ php_errors\.log/error_log\ =\ \/var\/log\/php_errors\.log/g" /etc/php.ini \
    && echo "ServerTokens Prod" >> /etc/httpd/conf/httpd.conf \
    && echo "ServerSignature Off" >> /etc/httpd/conf/httpd.conf

WORKDIR /var/www

COPY ./httpd.sh /httpd.sh

CMD "/httpd.sh"