#syntax=docker/dockerfile:1.4.2

FROM nixos/nix:2.10.3@sha256:c6c9e6bf8d2d87877ef931bbf5c350d84ac114e33a4abacc3f2e51dcbed25ea1 AS crun
# renovate: datasource=github-releases depName=containers/crun
ARG CRUN_VERSION=1.5
WORKDIR /crun
RUN test -n "${CRUN_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --recursive --branch "${CRUN_VERSION}" \
        https://github.com/containers/crun.git .
RUN mkdir -p /usr/local/bin/ /usr/local/share/man/man1/  \
 && nix build -f nix --extra-experimental-features nix-command \
 && cp -rfp ./result/bin/crun /usr/local/bin/ \
 && cp *.1 /usr/local/share/man/man1/

FROM scratch AS local
COPY --from=crun /usr/local/bin/crun ./bin/
COPY --from=crun /usr/local/share/man ./share/man/
