FROM quay.io/keycloak/keycloak:21.0.1@sha256:057e1264cae9adbd9be65235d0c837087b0accc183275803b7da81b1b7a2a94c as builder

ENV KC_DB=mariadb
ENV KC_METRICS_ENABLED=true
ENV KC_HEALTH_ENABLED=true
ENV KC_HTTP_RELATIVE_PATH=/auth

# renovate: datasource=github-releases depName=sventorben/keycloak-restrict-client-auth
ENV RESTRICT_CLIENT_AUTH_VERSION="${RESTRICT_CLIENT_AUTH_VERSION:-v20.0.1}"

RUN mkdir -p /opt/keycloak/providers && \
    curl -SsfL -o \
        /opt/keycloak/providers/keycloak-restrict-client-auth.jar \
        "https://github.com/sventorben/keycloak-restrict-client-auth/releases/download/${RESTRICT_CLIENT_AUTH_VERSION}/keycloak-restrict-client-auth.jar" && \
    /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:21.0.1@sha256:057e1264cae9adbd9be65235d0c837087b0accc183275803b7da81b1b7a2a94c

LABEL maintainer="ownCloud GmbH"
LABEL org.opencontainers.image.authors="ownCloud GmbH"
LABEL org.opencontainers.image.title="Keycloak"
LABEL org.opencontainers.image.url="https://github.com/owncloud-ops/keycloak"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ops/keycloak"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ops/keycloak"

ARG GOMPLATE_VERSION
ARG WAIT_FOR_VERSION
ARG CONTAINER_LIBRARY_VERSION

# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ENV GOMPLATE_VERSION="${GOMPLATE_VERSION:-v3.11.4}"
# renovate: datasource=github-releases depName=thegeeklab/wait-for
ENV WAIT_FOR_VERSION="${WAIT_FOR_VERSION:-v0.3.0}"
# renovate: datasource=github-releases depName=owncloud-ops/container-library
ENV CONTAINER_LIBRARY_VERSION="${CONTAINER_LIBRARY_VERSION:-v0.1.0}"

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --from=builder /opt/keycloak/providers/ /opt/keycloak/providers/
ADD overlay/ /

USER 0

RUN microdnf install -y openssl nmap-ncat tar gzip && \
    curl -SsfL -o /usr/local/bin/gomplate "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64" && \
    curl -SsfL -o /usr/local/bin/wait-for "https://github.com/thegeeklab/wait-for/releases/download/${WAIT_FOR_VERSION}/wait-for" && \
    curl -SsfL "https://github.com/owncloud-ops/container-library/releases/download/${CONTAINER_LIBRARY_VERSION}/container-library.tar.gz" | tar xz -C / && \
    chmod 755 /usr/local/bin/gomplate && \
    chmod 755 /usr/local/bin/wait-for && \
    mkdir -p /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies && \
    chown -R 1000:root /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies && \
    chmod 0755 /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies && \
    microdnf clean all && \
    rm -rf /var/cache/yum/*

USER 1000

WORKDIR /opt/keycloak
ENTRYPOINT ["/usr/bin/entrypoint"]
HEALTHCHECK --interval=5s --timeout=5s --retries=10 CMD /usr/bin/healthcheck
CMD []
