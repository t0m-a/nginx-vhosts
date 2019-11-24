###### 80 to 443 ALL Trafic Redirect to HTTPS-HSTS
server {
	listen       80;
	server_name  $SERVER_NAME;
	return 301 https://$server_name$request_uri;
	access_log  /var/log/nginx/access.log;
}
###### Main Server : PROXY SSL
server {
         listen       443 ssl;
         server_name  $SERVER_NAME;
		 access_log  /var/log/nginx/access.log;

         ssl_certificate      /etc/letsencrypt/live/$SERVER_NAME/fullchain.pem;
         ssl_certificate_key  /etc/letsencrypt/live/$SERVER_NAME/privkey.pem;

         ssl_session_cache    shared:SSL:50m;
         ssl_session_timeout  10m;
         keepalive_timeout      60;
         ssl_ciphers  HIGH:!aNULL:!MD5;
         ssl_prefer_server_ciphers  on;

         add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";

		location /robots.txt {return 200 "User-agent: *\nDisallow: /\n";}

# ROOT       
	 location / {

                root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                autoindex on;
				autoindex_exact_size off;

				location /robots.txt {return 200 "User-agent: *\nDisallow: /\n";}
                
      	 }	

# LOGS
	 location /logs {

                root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                index  index.html;
                auth_basic "logs";
                auth_basic_user_file /etc/nginx/htpasswd;
      	 }

     location /logs/webservers {

                root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                index  index.html;
                auth_basic "logs";
                auth_basic_user_file /etc/nginx/htpasswd;
         }

# REPOS
        location /repo {

		root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                autoindex on;
                autoindex_exact_size off;
                auth_basic "repo";
                auth_basic_user_file /etc/nginx/htpasswd;
	}

     location /bin {

                root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                autoindex on;
                autoindex_exact_size off;
				auth_basic "repo";
                auth_basic_user_file /etc/nginx/htpasswd;
	}

# MUNIN Monitoring	
	location /munin/static/ {

				alias /etc/munin/static/;
				expires modified +1w;
	}

    location /munin/ {

                alias /var/cache/munin/www/;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                index  index.html;
                auth_basic "monit";
                auth_basic_user_file /etc/nginx/htpasswd;
				expires modified +310s;
        }

 	location ^~ /munin-cgi/munin-cgi-graph/ {
				access_log off;
				fastcgi_split_path_info ^(/munin-cgi/munin-cgi-graph)(.*);
				fastcgi_param PATH_INFO $fastcgi_path_info;
				fastcgi_pass unix:/var/run/munin/fcgi-graph.sock;
				include fastcgi_params;
	}

# MRTG Monitoring
        location /mrtg/ {

		root /var/www/html;
                add_header Strict-Transport-Security "max-age=2592000; includeSubdomains";
                index  index.html;
                auth_basic "monit";
                auth_basic_user_file /etc/nginx/htpasswd;

   		}
		
# PROXY PASS PHP 

		#location ~ \.php {
    	#proxy_pass http://SERVER_LOCAL_IP:8080;
	 	#proxy_set_header Host $host;
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_set_header X-Forwarded-Proto $scheme;
		#}
}
