FROM matrixdotorg/synapse:latest

# Install Backblaze S3 storage provider plugin
RUN pip install --no-cache-dir matrix-synapse-s3-storage-provider

WORKDIR /data

COPY homeserver.yaml /data/homeserver.yaml.template

# Startup script to inject Render Environment Variables into homeserver.yaml
RUN echo '#!/bin/sh' > /data/start.sh && \
    echo 'sed -e "s|SERVER_NAME_PLACEHOLDER|${SYNAPSE_SERVER_NAME}|g" \' >> /data/start.sh && \
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

CMD ["/data/start.sh"]
