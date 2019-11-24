# User-Agent filtering
# We filter bots and monitoring tools from the logs
map $http_user_agent $log_ua {

~Googlebot 0;
~Baiduspider 0;
~DotBot 0;
~Bingbot 0;
~Slurp 0;
~DuckDuckBot 0;
~YandexBot 0;
~Amazon* 0;

 default 1;
}

# Main server
# 80 to 443 ALL Trafic Redirect to HTTPS-HSTS
server {
	listen 80;
	server_name $DOMAIN_NAME;
	return 301 https://$DOMAIN_NAME$request_uri;
	access_log  /var/log/nginx/main_access.log;
}

# Redirect a previous domain name to a new one catch all plain HTTP
server {
        listen 80;
        server_name $OLD_DOMAIN_NAME;
        return 301 https://$DOMAIN_NAME$request_uri;
}

# Redirect all request to the previous domain to the new one over HTTPS
server {
        listen 443 ssl;
        ssl_certificate      /etc/letsencrypt/live/$OLD_DOMAIN_NAME/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/$OLD_DOMAIN_NAME/privkey.pem;
        server_name $OLD_DOMAIN_NAME;
	return 301 https://$DOMAINE_NAME$request_uri;
}
# Secondary SSL Server
server {
        listen 443 ssl;

        server_name $DOMAIN_NAME;
	access_log  /var/log/nginx/main_access.log combined if=$log_ua;
	error_log  /var/log/nginx/main_error.log;

# Prevent cross-side scripting 
	add_header X-Frame-Options DENY;
	add_header X-XSS-Protection "1; mode=block";
	add_header X-Content-Type-Options nosniff;

        ssl_certificate      /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
        ssl_certificate_key  /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
        ssl_session_cache    shared:SSL:10m;
        ssl_session_timeout  10m;
        keepalive_timeout      60;
        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;
        root /var/www/main;
	include conf.d/restrictions.conf;
	include conf.d/wordpress.conf;

# Blog page configration - Wordpress PHP  
	location / {
               
		if ($http_user_agent ~* Pingdom.* ) {
                access_log off;
                return 200;
                }

        add_header X-Frame-Options DENY;
		add_header X-XSS-Protection "1; mode=block";
		add_header X-Content-Type-Options nosniff;                
		autoindex off;
		autoindex_exact_size off;
		client_max_body_size 13m;
		index index.php index.html index.htm;
		try_files $uri $uri/ /index.php?$query_string;		

        }
	
	location ~* \.php$ {
		fastcgi_pass unix:/run/php/php7.0-fpm.sock;
		include fastcgi.conf;
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_param PATH_INFO $fastcgi_path_info;
		fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
		fastcgi_param SCRIPT_FILENAME $document_root/$fastcgi_script_name;
	}

	location ~ /favicon.ico {
        access_log off;
        log_not_found off;
    }	

location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
}

location ~ /\. {
        deny all;
}

location ~* /(?:uploads|files)/.*\.php$ {
        deny all;
}

 location ^~ /wp-cron.php {
	deny all;        
	return 444;
    }

# Redirecting a location to another site on another domain
location /photo/ {
rewrite ^ https://$ANOTHER_DOMAIN_NAME/;
}

}
