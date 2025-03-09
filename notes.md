# Nginx

- High-performance webserver, reverse proxy, load balancer

## Main Principles

### 1. Event-Driven Architecture

- Uses an async, non-blocking event loop instead of creating new threads/processes for each request
- Efficiently handles thousands of concurrent connections with minimal resource usage

### 2. Modular and configurable

- Configuration is declarative and structured in a hierarchical format
- Modules allow extending Nginx functionalities (e.g., caching, authentication, security)

### 3. Reverse Proxy and Load Balancing

- Acts as intermediary between clients and backend servers
- Supports multiple load-balancing algorithms
  - Round-robin (default)
  - Least connections
  - IP Hash
- Improves scalability and fault tolerance

### 4. Static and dynamic content handling

- Static content (HTML, CSS, JS, images, videos) is served directly from the filesystem, reducing backend load
- Dynamic content (PHP, Python, Node.js, etc) is processed via FastCGI, uWSGI, or proxied to application servers

### 5. Security and Access Control

- Supports TLS/SSL encryption for HTTPS
- Rate limiting, DDoS protection, and IP Filtering
- Configurable request and response headers for security hardening

### 6. Caching for performance

- Supports fast in-memory and disk-based caching
- Reduces database or backend server load by caching responses

### 7. Logging and monitoring

- Logs requests and errors in a structured format
- Compatible with logging tools like ELK Stack and Prometheus

### 8. Simple and readable configuration

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
