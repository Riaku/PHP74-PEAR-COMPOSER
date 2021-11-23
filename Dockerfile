ARG BASE_REGISTRY=registry1.dso.mil
ARG BASE_IMAGE=ironbank/opensource/php/php74
ARG SHA256=7c2b21573f23b0b9235a737e0438a83340f21f18b202bb63119dd9d473cd995e

FROM ${BASE_REGISTRY}/${BASE_IMAGE}@sha256:${SHA256}

COPY go-pear.phar composer.phar ./

USER 0

COPY certs /etc/pki/ca-trust/source/anchors
RUN update-ca-trust

RUN dnf update --setopt=tsflags=nodocs -y && \
    dnf clean all && \
    rm -rf /var/cache/dnf && \
    php go-pear.phar && \
    chmod +x ./composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    rm go-pear.phar

USER 1001

WORKDIR "/var/www/html"

ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]

HEALTHCHECK \
  CMD curl -s http://localhost:9000; if [ $? = 56 ]; then exit 0; else exit 1; fi 