# Nginx

- High-performance webserver, reverse proxy, load balancer

## 1. Main Principles

### 1.1 Event-Driven Architecture

- Uses an async, non-blocking event loop instead of creating new threads/processes for each request
- Efficiently handles thousands of concurrent connections with minimal resource usage
- Unlike traditional web servers (e.g., Apache), which create a nre process/thread per request, Ngix uses a single-threaded event loop with non-blocking I/O.

#### 1.1.1. Benefits

- High concurrency with low memory and CPU usage
- Efficient under high loads and scalable with minimal resource consumption

### 1.2. Modular and configurable

- Configuration is declarative and structured in a hierarchical format
- Modules allow extending Nginx functionalities (e.g., caching, authentication, security)
- Features like load balancing, caching and security are implemented as modules
- Core functionality (HTTP, TCP, SSL, etc) is built-in, while optional features can be enabled via dynamic/static modules

### 1.3. Reverse Proxy and Load Balancing

- Acts as intermediary between clients and backend servers
- Supports multiple load-balancing algorithms
  - Round-robin (default)
  - Least connections
  - IP Hash
- Improves scalability and fault tolerance
- Reverse proxy: Nginx acts as an intermediary, forwarding client requests to backend servers
- Load balancing: distributes traffic among multiple backend servers to improve performance and availability

### 1.4. Static and dynamic content handling

- Static content (HTML, CSS, JS, images, videos) is served directly from the filesystem, reducing backend load
- Dynamic content (PHP, Python, Node.js, etc) is processed via FastCGI, uWSGI, or proxied to application servers

### 1.5. Security and Access Control

- Supports TLS/SSL encryption for HTTPS
- Rate limiting, DDoS protection, and IP Filtering
- Configurable request and response headers for security hardening

### 1.6. Caching for performance

- Supports fast in-memory and disk-based caching
- Reduces database or backend server load by caching responses

### 1.7. Logging and monitoring

- Logs requests and errors in a structured format
- Compatible with logging tools like ELK Stack and Prometheus

### 1.8. Simple and readable configuration

- Uses a declartive, bloc-based configuration (`nginx.conf`)

```
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
    }
}
```

## 2. Fundamentals

### 2.1 First steps

```bash
brew install nginx
cd /usr/local/etc/nginx # to check the content
nginx # to run nginx => accessed on localhost:8080
nginx -s reload # to reload nginx server
```

### 2.2 Nginx File

```
# main config
user www-data;
worker_processes auto;

# event handling context
events { # context
    worker_connections 1024; # directive
}

# http config
http {
    include mime.types
    default_type application/actet-stream;

    # logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;

    # gzip compression
    gzip on;

    # virtual server (host)
    server {
        listen 80;
        server_name example.com;

        location / {
            root /var/www/html;
            index index.html
        }

        location /api/ {
            proxy_pass http://backend;
        }
    }
}
```

### 2.3 Terminology

#### 2.3.1 Directives

- A directive is a configuration instruction

```
directive_name value;

# example
worker_processes auto;
```

#### 2.3.2 Contexts (blocks)

- Used to group directives
- They are enclosed `{}` and can contain other contexts or directives

##### 1. Main context (`nginx.conf` global settings)

- Defines high-level settings
- Directives inside: `user`, `worker_processes`, `pid`, `error_log`

```nginx
user www-data;
worker_processes auto;
```

##### 2. Event context

- Controls how Nginx handles connections
- Directives inside: `worker_connections`, `use`

```
events {
    worker_connections 1024;
}
```

##### 3. HTTP Context

- Directives inside: `include`, `gzip`, `log_format`, `server`

```
http {
    include mime.types;
    gzip on;
}
```

##### 4. Server context

- Defines a virtual host (website or application)
- Directives inside: `listen`, `server_name`, `location`

```
server {
    listen 80;
    server_name example.com;
}
```

##### 5. Location context

- Defines how Nginx handles specific URL patterns
- Used inside `server`

```
location / {
    root /var/www/html;
    index index.html
}
```

#### 2.3.4 Syntax rules

- (`;`): end of each directive
- (`{}`): enclose blocks
- (`#`): commends. ignored by Nginx

## 3. Nginx CLI commands

- You might need to add `sudo` before the commands since Nginx runs as a system process

```bash
# Basic commands
nginx # starts nginx with default config
nginx -s stop # kills its processes
nginx -s quit # shutdowm
nginx -s reload # applies config changes without downtime
nginx -s stop && nginx # restarts it
nginx -c /path/to/nginx.conf # run nginx with custom config

# debugging
ps aux | grep nginx # check if it's running
nginx -t # check for errors

# view logs (errors and access)
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log

# process management
pgrep nginx # find nginx process ID (PID)
kill -QUIT <PID> # kill Nginx process

# others
nginx -t && nginx -s reload # test config and restart if valid
```

## 4. Serving static content

1. Create project folder
2. Add static files
3. Create custom `nginx.conf`

```nginx
# example
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    server {
        listen 8080; the port where Nginx will serve content

        root /path/to/folder;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html
        }
    }
}
```

4. Run custom `nginx.conf`

- Nginx doesn't resolve relative paths based on the current working directory
- It expects a fully qualified **absolute path** to the config file

```
nginx -c absolute/path/to/custom/nginx.conf # run
nginx -c absolute/path/to/custom/nginx.conf -s stop # stop

# tip: dynamically getting the absolute path with `$(pwd)`
nginx -c $(pwd)/nginx.conf
nginx -c $(pwd)/nginx.conf -s stop
```

## 5. Serving static content inside a container

1. Create `nginx.conf`

```
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;  # nginx runs inside the container on port 80

        root /usr/share/nginx/html;  # Change this to your actual path
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}

```

2. Create dockerfile

```
nano Dockerfile
```

3. Setup dockerfile

```Dockerfile
# official image nginx
FROM nginx:latest

# copy custom config to Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# copy static files to the Nginx web root
COPY public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

4. Setup docker-compose

```yml
services:
  nginx:
    build: .
    container_name: nginx-container
    ports:
      - "8080:80"
    restart: unless-stopped
    volumes:
      - ./public:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf
```

5. Manage docker-compose

```
docker-compose down
docker-compose up --build -d
```
