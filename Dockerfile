# Railway template: n8n, pinned to a tested release (2.42.3, by digest), 3.0-ready defaults, owner created from variables (no open
# setup page on a public URL). The image is the official n8nio/n8n; this layer only adds start.sh.
FROM n8nio/n8n:2.42.3@sha256:240eaa2a3d491adac5817aa4c3f1c521bb18ec79f6e448517158d5220ee0f37b
COPY --chown=node:node start.sh /home/node/start.sh
USER root
RUN chmod 0755 /home/node/start.sh
# starts as root ONLY to fix the owner of the volume (Railway mounts volumes root-owned); start.sh then drops to user node
# (uid 1000) before n8n starts - n8n never runs as root.
ENTRYPOINT ["tini", "--", "/home/node/start.sh"]
