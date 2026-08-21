FROM matrixdotorg/synapse:latest

# Install S3 storage plugin
RUN pip install --no-cache-dir synapse-s3-storage-provider

WORKDIR /data

COPY homeserver.yaml /data/homeserver.yaml.template

# Startup script generating random secret keys if not set, then replacing placeholders
RUN echo '#!/bin/sh' > /data/start.sh && \
    echo 'MACAROON_SECRET="${MACAROON_SECRET:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}"' >> /data/start.sh && \
    echo 'FORM_SECRET="${FORM_SECRET:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}"' >> /data/start.sh && \
    echo 'REG_SECRET="${REGISTRATION_SHARED_SECRET:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)}"' >> /data/start.sh && \
    echo 'sed -e "s|SERVER_NAME_PLACEHOLDER|${SYNAPSE_SERVER_NAME}|g" \' >> /data/start.sh && \
    echo '    -e "s|MACAROON_SECRET_PLACEHOLDER|${MACAROON_SECRET}|g" \' >> /data/start.sh && \
    echo '    -e "s|FORM_SECRET_PLACEHOLDER|${FORM_SECRET}|g" \' >> /data/start.sh && \
    echo '    -e "s|REG_SECRET_PLACEHOLDER|${REG_SECRET}|g" \' >> /data/start.sh && \
    echo '    -e "s|DB_USER_PLACEHOLDER|${DB_USER}|g" \' >> /data/start.sh && \
    echo '    -e "s|DB_PASSWORD_PLACEHOLDER|${DB_PASSWORD}|g" \' >> /data/start.sh && \
    echo '    -e "s|DB_HOST_PLACEHOLDER|${DB_HOST}|g" \' >> /data/start.sh && \
    echo '    -e "s|DB_NAME_PLACEHOLDER|${DB_NAME:-neondb}|g" \' >> /data/start.sh && \
    echo '    -e "s|B2_BUCKET_PLACEHOLDER|${B2_BUCKET}|g" \' >> /data/start.sh && \
    echo '    -e "s|B2_ENDPOINT_PLACEHOLDER|${B2_ENDPOINT}|g" \' >> /data/start.sh && \
    echo '    -e "s|B2_REGION_PLACEHOLDER|${B2_REGION:-us-east-005}|g" \' >> /data/start.sh && \
    echo '    -e "s|B2_ACCESS_KEY_PLACEHOLDER|${B2_ACCESS_KEY}|g" \' >> /data/start.sh && \
    echo '    -e "s|B2_SECRET_KEY_PLACEHOLDER|${B2_SECRET_KEY}|g" \' >> /data/start.sh && \
    echo '    /data/homeserver.yaml.template > /data/homeserver.yaml' >> /data/start.sh && \
    echo 'exec python3 -m synapse.app.homeserver --config-path /data/homeserver.yaml' >> /data/start.sh && \
    chmod +x /data/start.sh

ENTRYPOINT []
CMD ["/data/start.sh"]
