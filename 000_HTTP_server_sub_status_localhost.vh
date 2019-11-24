# Nginx Web server sub_status display for monitoring accessible by localhost only 
server {
    location /nginx_status {
        stub_status on;
 
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}
