# keycloak

[![Build Status](https://drone.owncloud.com/api/badges/owncloud-ops/keycloak/status.svg)](https://drone.owncloud.com/owncloud-ops/keycloak/)
[![Docker Hub](https://img.shields.io/badge/docker-latest-blue.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/owncloudops/keycloak)
[![Quay.io](https://img.shields.io/badge/quay-latest-blue.svg?logo=docker&logoColor=white)](https://quay.io/repository/owncloudops/keycloak)

Custom container image for [Keycloak](https://www.keycloak.org/). For more details about optimized container images, see the Keycloak [documentation](https://www.keycloak.org/server/containers). The embedded healthcheck script is disabled by default and only works on an HTTP port.

## Ports

- 8080
- 8443

## Build Environment

```Shell
KC_DB=mariadb

KC_HEALTH_ENABLED=true
KC_METRICS_ENABLED=true

# If this value is changed, the health check script must also be adjusted.
KC_HTTP_RELATIVE_PATH=/auth
# If set and the specified file does not exist when the container is started,
# a new keystore for https certificates is automatically generated.
KC_HTTPS_KEY_STORE_FILE=

# Infinispan cache configuration. Note: The default local cache configuration
# from `cache-ispn-local.xml` only works on single node setups!
KC_CACHE=ispn
KC_CACHE_CONFIG_FILE=cache-ispn-local.xml

KC_TRANSACTION_XA_ENABLED=true
QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY=true
```

## Custom Providers

- [sventorben/keycloak-restrict-client-auth](https://github.com/sventorben/keycloak-restrict-client-auth)

## Build

```Shell
docker build -f Dockerfile -t keycloak:latest .
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/owncloud-ops/keycloak/blob/main/LICENSE) file for details.
