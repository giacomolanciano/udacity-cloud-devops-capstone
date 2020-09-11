FROM nginx:1.19.2

COPY ./src/index.html /usr/share/nginx/html/index.html

EXPOSE 80
