# Nginx Main Web Server
# MAIN SERVER BLOCK
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
        root /var/www/html;
        index index.html index.htm;

        location wiki {
        return 302 /wiki/;
        }
        location /wiki/ldap/ {
        auth_basic "Restricted Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        }
	location /mockup/ {
	autoindex on;
	disable_symlinks off;
	}
	location /mockup/wiki/ {
	return 302 /wiki/;
	}
	location logs {
	return 302 /logs/;
	}
	location /logs/ {
	auth_basic "Restricted Area";
	auth_basic_user_file /etc/nginx/.htpasswd;
	}
	# External redirection to blog for search engines
	location /blog {
	return 301 https://$ANOTHER_DOMAIN_NAME/;
	}

# End of SERVER BLOCK
}
