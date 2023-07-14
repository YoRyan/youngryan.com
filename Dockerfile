FROM nginxinc/nginx-unprivileged:stable-alpine
COPY _site /usr/share/nginx/html