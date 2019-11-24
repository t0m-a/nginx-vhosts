# nginx-vhosts
Nginx Web Server configurations files examples for Wordpress, proxies, phpMyAdmin, Docker, Grafana, InfluxDB, monitoring tools and more...

I mean to use these files as #devOps tools to centralize my configurations and remotely GET them.

----
## Usage
1. .vh files are virtual hosts.
2. .conf are Nginx config files.
3. For Docker .conf files contains also the virtual host.

----
## Variables in files

*Replace $DOMAIN\_NAME, $NEW\_DOMAIN\_NAME, $SERVER\_NAME, etc... with your own domain or hostname*

**You should never use variables in Nginx virtual hosts files**

>Q: Is there a proper way to use nginx variables to make sections of the configuration shorter, using them as macros for making parts of configuration work as templates?

>A: Variables should not be used as template macros. Variables are evaluated in the run-time during the processing of each request, so they are rather costly compared to plain static configuration. Using variables to store static strings is also a bad idea. Instead, a macro expansion and "include" directives should be used to generate configs more easily and it can be done with the external tools, e.g. sed + make or any other common template mechanism.

[Nginx FAQ](http://nginx.org/en/docs/faq/variables_in_config.html)

The only variables tolerated in Nginx config files is $hostname


