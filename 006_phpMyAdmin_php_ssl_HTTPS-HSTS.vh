# 80 to 443 ALL Trafic Redirect to HTTPS-HSTS
server {
				listen 80;
				server_name $DOMAIN_NAME;
				return 301 https://$DOMAIN_NAME$request_uri;
				access_log  /var/log/nginx/pma_redir_access.log;
}
# SSL Server- PMA
server {
				listen 443 ssl;
				server_name $DOMAIN_NAME;
				access_log  /var/log/nginx/pma_access.log;
				error_log  /var/log/nginx/pma_error.log;
				ssl_certificate      /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
				ssl_certificate_key  /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
				ssl_session_cache    shared:SSL:50m;
				ssl_session_timeout  10m;
				keepalive_timeout      60;
				ssl_ciphers  HIGH:!aNULL:!MD5;
				ssl_prefer_server_ciphers  on;
				add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
				root /var/www/phpmyadmin;

# PMA page - PMA PHP        

	location /phpmyadmin {               
				add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                #auth_basic "Restricted Access";
                #auth_basic_user_file /etc/nginx/htpasswd;
				root /usr/share/;
				index index.php index.html index.htm;
				}
    location ~ ^/phpmyadmin/(.+\.php)$ {
	            try_files $uri =404;
	            root /usr/share/;
				fastcgi_pass unix:/run/php/php7.0-fpm.sock;
           		fastcgi_param HTTPS on;
           		fastcgi_index index.php;
           		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
           		include /etc/nginx/fastcgi_params;
               }
        location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }

        location /phpMyAdmin {
               rewrite ^/* /phpmyadmin last;
        }	

# Deny Apache Files Access and no favicon loggin
	location ~ /\.ht {
                deny all;
    	}
		
	location ~ /favicon.ico {
				access_log off;
				log_not_found off;
   	}	
}
