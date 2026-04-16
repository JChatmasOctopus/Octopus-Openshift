ARG UPSTREAM_IMAGE=octopusdeploy/octopusdeploy:2026.1.11242

FROM ${UPSTREAM_IMAGE} AS upstream

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ARG OCTOPUS_VERSION="2026.1.11242"

LABEL name="octopusdeploy-server-ubi-example" \
      vendor="Octopus Deploy" \
      version="${OCTOPUS_VERSION}" \
      summary="Example Octopus Deploy Server image rebased onto UBI for OpenShift-style environments"

ENV OCTOPUS_INSTANCE="OctopusServer" \
    ACCEPT_EULA="N" \
    LANG="en_US.UTF-8" \
    HOME="/tmp" \
    XDG_RUNTIME_DIR="/tmp/octopus-runtime" \
    COMPlus_DbgEnableMiniDump="1"

RUN microdnf update -y && \
    microdnf install -y \
        ca-certificates \
        libicu \
        openssl \
        krb5-libs \
        zlib \
        libstdc++ \
        findutils \
        procps-ng \
        hostname \
        gzip \
        tar \
    && microdnf clean all

RUN mkdir -p \
      /Octopus \
      /etc/octopus \
      /repository \
      /artifacts \
      /taskLogs \
      /cache \
      /import \
      /eventExports \
      /diagnostics \
      /tmp/octopus-runtime

COPY --from=upstream /Octopus /Octopus

WORKDIR /Octopus

RUN chmod +x \
      /Octopus/install.sh \
      /Octopus/healthcheck.sh \
      /Octopus/createdump \
      /Octopus/Octopus.Server \
 && chgrp -R 0 \
      /Octopus \
      /etc/octopus \
      /repository \
      /artifacts \
      /taskLogs \
      /cache \
      /import \
      /eventExports \
      /diagnostics \
      /tmp/octopus-runtime \
 && chmod -R g=u \
      /Octopus \
      /etc/octopus \
      /repository \
      /artifacts \
      /taskLogs \
      /cache \
      /import \
      /eventExports \
      /diagnostics \
      /tmp/octopus-runtime

EXPOSE 8080 443 10943 8443

VOLUME ["/repository", "/artifacts", "/taskLogs", "/cache", "/import", "/eventExports", "/diagnostics"]

HEALTHCHECK --start-period=5m CMD /Octopus/healthcheck.sh

ENTRYPOINT ["./install.sh"]
CMD [""]
