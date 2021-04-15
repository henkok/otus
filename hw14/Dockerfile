FROM alpine:3.12
RUN set -x \
    && apk update \
    && apk add nginx \
        vim \
        curl \
	bash \
    && mkdir -p /usr/share/nginx/html
COPY nginx/index.html /usr/share/nginx/html/index.html
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
