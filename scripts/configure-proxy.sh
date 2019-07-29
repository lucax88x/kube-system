#!/bin/bash

# Install haproxy
apt-get -y install haproxy

# Configure haproxy
cat > /etc/default/haproxy <<EOD
# Set ENABLED to 1 if you want the init script to start haproxy.
ENABLED=1
# Add extra flags here.
#EXTRAOPTS="-de -m 16"
EOD
  cat > /etc/haproxy/haproxy.cfg <<EOD

defaults
    log     global
    mode    http
    # option  httplog
    option  dontlognull
    timeout connect 5s
    timeout client 50s
    timeout server 50s
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

# frontend stats
#     bind *:8404
#     stats enable
#     stats uri /stats
#     stats refresh 10s
#     stats admin if { src 127.0.0.1 }

listen stats
    bind *:8404
    # stats auth admin:bdi2016
    stats uri /
    stats realm Haproxy\ Statistics
    stats enable
    mode http

# listen stats
#     bind *:8404
#     # stats auth admin:bdi2016
#     stats uri /stats
#     stats realm Haproxy\ Statistics
#     stats enable
#     stats refresh 10s
#     stats admin if { src 127.0.0.1 }
#     mode http    

frontend k8s-api
    bind 192.168.205.5:443
    bind 127.0.0.1:443
    mode tcp
    # option tcplog    
    default_backend k8s-api

backend k8s-api
    mode tcp
    # option tcplog
    # option tcp-check
    balance roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

    server apiserver1 192.168.205.10:6443 check
    server apiserver2 192.168.205.11:6443 check
    server apiserver3 192.168.205.12:6443 check
EOD
    
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
/usr/sbin/service haproxy restart
