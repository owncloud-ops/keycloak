# keycloak

[![Build Status](https://drone.owncloud.com/api/badges/owncloud-ops/keycloak/status.svg)](https://drone.owncloud.com/owncloud-ops/keycloak/)
[![Docker Hub](https://img.shields.io/badge/docker-latest-blue.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/owncloudops/keycloak)

Custom container image for [Keycloak](https://www.keycloak.org/). More details about optimized container images can be found in the Keycloak [documentation](https://www.keycloak.org/server/containers).

## Ports

- 8080
- 8443

## Build Environment

```Shell
KC_DB=mariadb
KC_HEALTH_ENABLED=true
KC_METRICS_ENABLED=true
KC_HTTP_RELATIVE_PATH=/auth
```

## Custom Providers

- [sventorben/keycloak-restrict-client-auth](https://github.com/sventorben/keycloak-restrict-client-auth)

## Build

```Shell
docker build -f Dockerfile -t keycloak:latest .
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/owncloud-ops/keycloak/blob/main/LICENSE) file for details.
