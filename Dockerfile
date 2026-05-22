
FROM alpine:3.19 AS builder

WORKDIR /app

COPY index.html app.js ./


FROM nginx:1.25-alpine AS production


RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup


RUN rm -rf /usr/share/nginx/html/*


COPY --from=builder /app/index.html /app/app.js /usr/share/nginx/html/


COPY default.conf /etc/nginx/conf.d/default.conf


RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown appuser:appgroup /var/run/nginx.pid

USER appuser

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:80 || exit 1

CMD ["nginx", "-g", "daemon off;"]