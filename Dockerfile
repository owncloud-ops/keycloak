FROM registry.access.redhat.com/ubi9/ubi-minimal@sha256:2636170dc55a0931d013014a72ae26c0c2521d4b61a28354b3e2e5369fa335a3 as fetcher

ARG GOMPLATE_VERSION
ARG WAIT_FOR_VERSION
ARG CONTAINER_LIBRARY_VERSION
ARG RESTRICT_CLIENT_AUTH_VERSION

# renovate: datasource=github-releases depName=hairyhenderson/gomplate
ENV GOMPLATE_VERSION="${GOMPLATE_VERSION:-v3.11.7}"
# renovate: datasource=github-releases depName=thegeeklab/wait-for
ENV WAIT_FOR_VERSION="${WAIT_FOR_VERSION:-v0.4.2}"
# renovate: datasource=github-releases depName=owncloud-ops/container-library
ENV CONTAINER_LIBRARY_VERSION="${CONTAINER_LIBRARY_VERSION:-v0.1.0}"
# renovate: datasource=github-releases depName=sventorben/keycloak-restrict-client-auth
ENV RESTRICT_CLIENT_AUTH_VERSION="${RESTRICT_CLIENT_AUTH_VERSION:-v24.0.0}"

RUN microdnf install -y tar gzip && \
    mkdir -p /opt/fetcher && \
    mkdir -p /opt/fetcher/container-library && \
    curl -SsfL -o /opt/fetcher/gomplate "https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64" && \
    curl -SsfL -o /opt/fetcher/wait-for "https://github.com/thegeeklab/wait-for/releases/download/${WAIT_FOR_VERSION}/wait-for" && \
    curl -SsfL "https://github.com/owncloud-ops/container-library/releases/download/${CONTAINER_LIBRARY_VERSION}/container-library.tar.gz" \
        | tar xz -C /opt/fetcher/container-library && \
    curl -SsfL -o /opt/fetcher/keycloak-restrict-client-auth.jar \
        "https://github.com/sventorben/keycloak-restrict-client-auth/releases/download/${RESTRICT_CLIENT_AUTH_VERSION}/keycloak-restrict-client-auth.jar"

FROM quay.io/keycloak/keycloak:24.0.3@sha256:4d6f22991266b4c4b0b1924f5f91a4e6197e33100e5eac504a490ae78495c7e0 as builder

ARG KC_DB=mariadb
ARG KC_METRICS_ENABLED=true
ARG KC_HEALTH_ENABLED=true
ARG KC_HTTP_RELATIVE_PATH=/auth
ARG KC_FEATURES=recovery-codes
ARG KC_CACHE=ispn
ARG KC_CACHE_CONFIG_FILE=cache-ispn-local.xml
ARG KC_TRANSACTION_XA_ENABLED=true

COPY --from=fetcher --chown=1000 /opt/fetcher/keycloak-restrict-client-auth.jar /opt/keycloak/providers/keycloak-restrict-client-auth.jar
ADD overlay/opt/keycloak/conf/ /opt/keycloak/conf/

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:24.0.3@sha256:4d6f22991266b4c4b0b1924f5f91a4e6197e33100e5eac504a490ae78495c7e0

LABEL maintainer="ownCloud GmbH"
LABEL org.opencontainers.image.authors="ownCloud GmbH"
LABEL org.opencontainers.image.title="Keycloak"
LABEL org.opencontainers.image.url="https://github.com/owncloud-ops/keycloak"
LABEL org.opencontainers.image.source="https://github.com/owncloud-ops/keycloak"
LABEL org.opencontainers.image.documentation="https://github.com/owncloud-ops/keycloak"

ENV QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY=true

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --from=builder /opt/keycloak/providers/ /opt/keycloak/providers/
COPY --from=fetcher /opt/fetcher/gomplate /usr/local/bin/gomplate
COPY --from=fetcher /opt/fetcher/wait-for /usr/local/bin/wait-for
COPY --from=fetcher /opt/fetcher/container-library/ /
ADD overlay/ /

USER 0

RUN chmod 755 /usr/local/bin/gomplate && \
    chmod 755 /usr/local/bin/wait-for && \
    mkdir -p /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies /opt/keycloak/cache && \
    chown -R 1000:root /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies /opt/keycloak/cache /opt/keycloak/conf && \
    chmod 0755 /opt/keycloak/themes /opt/keycloak/providers /opt/keycloak/dependencies && \
    chmod 0700 /opt/keycloak/cache /opt/keycloak/conf

USER 1000

WORKDIR /opt/keycloak
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD []
