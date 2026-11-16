# Railway template: n8n, pinned to a tested release (2.47.7, by digest), 3.0-ready defaults, owner created from variables (no open
# setup page on a public URL). The image is the official n8nio/n8n; this layer only adds start.sh.
FROM n8nio/n8n:2.47.7@sha256:b4b90747b81fcda7e76550c0d3aa7f0f64917a1e9573cff40d6834eaf2e0f8ea
COPY --chown=node:node start.sh /home/node/start.sh
USER root
RUN chmod 0755 /home/node/start.sh
# starts as root ONLY to fix the owner of the volume (Railway mounts volumes root-owned); start.sh then drops to user node
# (uid 1000) before n8n starts - n8n never runs as root.
ENTRYPOINT ["tini", "--", "/home/node/start.sh"]
