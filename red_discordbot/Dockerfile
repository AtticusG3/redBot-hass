ARG PCX_TAG=latest
FROM phasecorex/red-discordbot:${PCX_TAG}

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG BUILD_VERSION=dev
ARG BUILD_ARCH=amd64

LABEL io.hass.version="${BUILD_VERSION}" \
      io.hass.type="app" \
      io.hass.arch="${BUILD_ARCH}"

COPY ha-entrypoint.sh /ha-entrypoint.sh
COPY bundled_cogs /opt/redbot-media-player/bundled_cogs
RUN chmod a+x /ha-entrypoint.sh

ENTRYPOINT ["/ha-entrypoint.sh"]
CMD ["/app/start-redbot.sh"]
