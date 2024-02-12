server {
    listen          80;
    access_log /home/ubuntu/cluster/favizone/log/web/app/app.favizone.com-access.log;
    error_log /home/ubuntu/cluster/favizone/log/web/app/app.favizone.com-error.log;

    server_name app.favizone.com;
    root /home/favizone/resources/upgrade/favizone; 

    access_log off;
    location ~ /.well-known/acme-challenge {
        allow all;
    }

    location ~ /\. { deny all; access_log off; log_not_found off; }

    location ~ /.well-known/acme-challenge {
        allow all;
    }
    
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
        proxy_pass http://localhost:8085;
        proxy_redirect off;
        proxy_hide_header "Content-Length";
        proxy_hide_header "Access-Control-Allow-Credentials";
        proxy_hide_header "Access-Control-Allow-Origin";

        if ($request_method = OPTIONS) {
            add_header 'Access-Control-Allow-Origin' "$http_origin" always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Max-Age' 1728000 always; # cache preflight value for 20 days
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since' always;
            add_header Content-Length 0 always;
            add_header 'Content-Type' 'text/plain charset=UTF-8' always;
            return 204;
        }

        if ($request_method = GET) {
            add_header 'Access-Control-Allow-Origin' "$http_origin" always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
        }

        if ($request_method = POST) {
            add_header 'Access-Control-Allow-Origin' "$http_origin" always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
        }
    }

    ### locations with timeout
    location /api/custom-scripts {
        include custom-conf/location.conf;
    }
    location /api/profile/register {
        include custom-conf/location.conf;
    }
    location /api/addEvent {
        include custom-conf/location.conf;
    }
}
