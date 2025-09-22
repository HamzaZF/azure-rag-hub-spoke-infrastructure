# Super simple Dockerfile - just serve static files
FROM nginx:alpine

# Copy static files
COPY index.html /usr/share/nginx/html/
COPY 404.html /usr/share/nginx/html/
COPY 50x.html /usr/share/nginx/html/

# Simple health endpoint
RUN echo 'server { \
    listen 80; \
    location /health { return 200 "healthy\\n"; add_header Content-Type text/plain; } \
    location / { root /usr/share/nginx/html; index index.html; try_files $uri $uri/ /index.html; } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
# Generate runtime config (BACKEND_API_URL) then start nginx
CMD /bin/sh -c "echo \"window.BACKEND_API_URL='\${BACKEND_API_URL:-}';\" > /usr/share/nginx/html/config.js && exec nginx -g 'daemon off;'"