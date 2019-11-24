# 80 to 443 ALL Trafic Redirect to HTTPS
server {
	listen 80;
	server_name $DOMAIN_NAME;
	return 301 https://$DOMAIN_NAME$request_uri;
	access_log /var/log/nginx/main_redir_access.log;
	error_log /var/log/nginx/main_redir_error.log;
	try_files $uri =404;
}

# Primary SSL server HTTPS-HSTS - tmsi.solutions
server {
        listen 443 ssl;
        server_name tmsi.solutions;
		access_log  /var/log/nginx/main_access.log;
		error_log  /var/log/nginx/main_error.log;

        ssl_certificate      /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
        ssl_session_cache    shared:SSL:50m;
        ssl_session_timeout  10m;
        keepalive_timeout      60;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;
        add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";

# Static content serve       
	location / {
                root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                autoindex off;
				autoindex_exact_size off;
				index index.html index.htm;
				try_files $uri $uri/ =404;
				#auth_basic "Work in progress";
                #auth_basic_user_file /etc/nginx/htpasswd;
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