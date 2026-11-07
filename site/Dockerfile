FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dd.html /tmp/dd.html
RUN { printf '<!doctype html>\n<html lang="ko">\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">\n'; cat /tmp/dd.html; } > /usr/share/nginx/html/index.html && rm /tmp/dd.html
