FROM nginx:1.19.2

COPY ./index.html /usr/share/nginx/html/index.html

EXPOSE 80
