FROM golang:1.16-alpine3.14 AS base
RUN apk add --update-cache --no-cache \
        git \
        make \
        gcc \
        pkgconf \
        musl-dev \
        btrfs-progs \
        btrfs-progs-dev \
        libassuan-dev \
        lvm2-dev \
        device-mapper \
        glib-static \
        libc-dev \
        gpgme-dev \
        protobuf-dev \
        protobuf-c-dev \
        libseccomp-dev \
        libseccomp-static \
        libselinux-dev \
        ostree-dev \
        openssl \
        iptables \
        bash \
        go-md2man

FROM base AS crun
RUN apk add --update-cache --no-cache \
        autoconf \
        automake \
        libtool
# renovate: datasource=github-releases depName=containers/crun
ARG CRUN_VERSION=1.3
WORKDIR /crun
RUN test -n "${CRUN_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --branch "${CRUN_VERSION}" \
        https://github.com/containers/crun.git .
RUN ./autogen.sh \
 && ./configure \
 && make \
        PKG_CONFIG='pkg-config --static' \
        CFLAGS='-std=c99 -Os -Wall -Wextra -Werror -static' \
        LDFLAGS='-s -w -static' \
 && make install

FROM scratch AS local
COPY --from=crun /usr/local/bin/crun .
