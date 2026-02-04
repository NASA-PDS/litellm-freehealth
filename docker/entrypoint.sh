#!/bin/sh

echo "Image tag: $IMAGE_TAG"

# Execute the script in the same directory as this entrypoint
SCRIPT_DIR="$(dirname "$0")"
"$SCRIPT_DIR"/create_nginx_conf.sh

echo "Using litellm callback:"
cat /etc/litellm/hook.py

# Start litellm from /app directory as a background process
"$SCRIPT_DIR"/docker/prod_entrypoint.sh --port 4000 --config /etc/litellm/config.yaml &

# Start nginx as a background service
nginx -g 'daemon off;' &

# Optionally, wait for background processes or keep the container alive
wait
