# User-Agent filtering

map $http_user_agent $log_ua {

~Googlebot 0;
aiduspider 0;
~DotBot 0;
ingbot 0;
~Slurp 0;
~DuckDuckBot 0;
~YandexBot 0;
~Amazon* 0;

 default 1;
}

# 80 to 443 ALL Trafic Redirect to HTTPS-HSTS
server {
	listen 80;
	server_name $DOMAIN_NAME;
	return 301 https://$DOMAIN_NAME$request_uri;
	access_log  /var/log/nginx/main_access.log;
}

# Secondary SSL Server
server {
        listen 443 ssl;

    server_name $DOMAIN_NAME;
	access_log  /var/log/nginx/$DOMAIN_NAME_access.log combined if=$log_ua;
	error_log  /var/log/nginx/$DOMAIN_NAMEmain_error.log;

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
	add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
	
    root /var/www/$DOMAIN_NAME;
	include conf.d/restrictions.conf;
	include conf.d/wordpress.conf;

# Blog page configuration - Wordpress PHP  
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

}
