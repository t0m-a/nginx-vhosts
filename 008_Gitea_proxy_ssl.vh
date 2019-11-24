# Nginx Gitea Proxy
server {
  listen 80;
  listen [::]:80;
  server_name $DOMAIN_NAME;
  return 301 https://$host$request_uri;
}
server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name $DOMAIN_NAME;
        ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.1 TLSv1;
        location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}
