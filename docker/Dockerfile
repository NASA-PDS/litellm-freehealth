FROM docker.litellm.ai/berriai/litellm-database:main-latest

ENTRYPOINT ["/bin/bash", "-c"]

ARG LITELLM_MASTER_KEY=sk-default

ENV LITELLM_MASTER_KEY=${LITELLM_MASTER_KEY}

# Install nginx
RUN apk update \
 && apk add --no-cache nginx

RUN adduser -D -g 'nginx' nginx

# Copy nginx config template
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY create_nginx_conf.sh /app/create_nginx_conf.sh
COPY config.yaml /etc/litellm/config.yaml

RUN chmod +x /app/create_nginx_conf.sh


# Expose proxy port
EXPOSE 4001
EXPOSE 4000

WORKDIR /app

# Start both the original service and nginx
CMD ["\
  ./create_nginx_conf.sh && \
  docker/prod_entrypoint.sh --port 4000 --config /etc/litellm/config.yaml & \
  nginx -g 'daemon off;' \
"]

