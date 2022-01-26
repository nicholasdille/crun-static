FROM nix AS crun
# renovate: datasource=github-releases depName=containers/crun
ARG CRUN_VERSION=1.4.2
WORKDIR /crun
RUN test -n "${CRUN_VERSION}" \
 && git clone --config advice.detachedHead=false --depth 1 --recursive --branch "${CRUN_VERSION}" \
        https://github.com/containers/crun.git .
RUN mkdir -p /usr/local/share/man/man1 \
 && nix build -f nix \
 && cp -rfp ./result/bin/crun /usr/local/bin/ \
 && cp *.1 /usr/local/share/man/man1/

FROM scratch AS local
COPY --from=crun /usr/local/bin/crun ./bin/
COPY --from=crun /usr/local/share/man ./share/man/
