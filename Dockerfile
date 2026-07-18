FROM node:22-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends cron ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash codex

RUN npm install --global @openai/codex@0.144.6

WORKDIR /app

ENV HOME="/home/codex"

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY codex-wakeup.sh /app/codex-wakeup.sh

RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh /app/codex-wakeup.sh \
    && mkdir -p /app/runtime /home/codex \
    && chown -R codex:codex /app/runtime /home/codex

VOLUME ["/home/codex"]

ENV CODEX_CRON_SCHEDULE="0 0,5,10,15,20 * * *" \
    TZ="UTC"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cron", "-f"]
