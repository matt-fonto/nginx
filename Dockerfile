# official image nginx
FROM nginx:latest 

# copy custom config to Nginx
COPY nginx.conf /etc/nginx/nginx.conf

COPY mime.types /etc/nginx/mime.types

# copy static files to the Nginx web root
COPY public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

