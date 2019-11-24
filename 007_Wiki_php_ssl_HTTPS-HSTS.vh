# HTTP Server Redirect
server {
	listen 80;
	server_name $DOMAIN_NAME;
	return 301 https://$DOMAIN_NAME$request_uri;
	access_log  /var/log/nginx/main_redir_access.log;
}
# HTTPS Server
server {
        listen       443 ssl;
        server_name  $DOMAIN_NAME;		
		access_log  /var/log/nginx/wiki_access.log;
		error_log  /var/log/nginx/wiki_error.log;
		try_files $uri =404;		
		root /var/www/$WIKI_FILES;
		ssl_certificate      /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
		ssl_certificate_key  /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
		ssl_session_cache    shared:SSL:50m;
		ssl_session_timeout  10m;
		keepalive_timeout      60;
		ssl_ciphers  HIGH:!aNULL:!MD5;
		ssl_prefer_server_ciphers  on;
		add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";

# Wiki page - Wiki PHP       
        location / {
                autoindex off;
                autoindex_exact_size off;
                index index.php index.html;
                try_files $uri $uri/ /index.php?$query_string;
                #auth_basic "Work in progress";
                #auth_basic_user_file /etc/nginx/htpasswd;
        }

        location ~* \.php$ {
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
                include fastcgi.conf;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_param PATH_INFO $fastcgi_path_info;
                fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
                fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
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
