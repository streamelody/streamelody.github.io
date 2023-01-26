#!/bin/bash
#First usable tylemp.sh on Debian 8 for 64M to 128M RAM VPS

function check_install {
	if [ -z "`which "$1" 2>/dev/null`" ]
	then
		executable=$1
		shift
		while [ -n "$1" ]
		do
		DEBIAN_FRONTEND=noninteractive apt-get -q -y --force-yes install "$1"
		print_info "$1 installed for $executable"
		shift
		done
	else
		print_warn "$2 already installed"
	fi
}

function check_remove {
	if [ -n "`which "$1" 2>/dev/null`" ]
	then
		DEBIAN_FRONTEND=noninteractive apt-get -q -y remove --purge "$2"
		print_info "$2 removed"
	else
		print_warn "$2 is not installed"
	fi
}

function check_sanity {
	# Do some sanity checking.
	if [ $(/usr/bin/id -u) != "0" ]
	then
		die 'Must be run by root user'
	fi

	if [ ! -f /etc/debian_version ]
	then
		die "Distribution is not supported"
	fi
}

function die {
	echo "ERROR: $1" > /dev/null 1>&2
	exit 1
}

function get_domain_name() {
	# Getting rid of the lowest part.
	domain=${1%.*}
	lowest=`expr "$domain" : '.*\.\([a-z][a-z]*\)'`
	case "$lowest" in
	com|net|org|gov|edu|co)
		domain=${domain%.*}
		;;
	esac
	lowest=`expr "$domain" : '.*\.\([a-z][a-z]*\)'`
	[ -z "$lowest" ] && echo "$domain" || echo "$lowest"
}

function get_password() {
	# Check whether our local salt is present.
	SALT=/var/lib/radom_salt
	if [ ! -f "$SALT" ]
	then
		head -c 512 /dev/urandom > "$SALT"
		chmod 400 "$SALT"
	fi
	password=`(cat "$SALT"; echo $1) | md5sum | base64`
	echo ${password:0:13}
}

function install_dash {
	check_install dash dash
	rm -f /bin/sh
	ln -s dash /bin/sh
}

function install_exim4 {
	check_install mail exim4
	if [ -f /etc/exim4/update-exim4.conf.conf ]
	then
		sed -i \
		"s/dc_eximconfig_configtype='local'/dc_eximconfig_configtype='internet'/" \
		/etc/exim4/update-exim4.conf.conf
		invoke-rc.d exim4 restart
	fi
}

function install_mysql {
	check_install mysqlcommon mysql-common
	mv /etc/mysql/my.cnf /etc/mysql/my.cnf.bak
        cat > /etc/mysql/my.cnf <<END
[mysqld]
[client]
port            = 3306
socket          = /var/run/mysqld/mysqld.sock


[mysqld_safe]
socket          = /var/run/mysqld/mysqld.sock
nice            = 0

[mysqld]
user            = mysql
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
port            = 3306
basedir         = /usr
datadir         = /var/lib/mysql
tmpdir          = /tmp
lc-messages-dir = /usr/share/mysql
skip-external-locking
bind-address            = 127.0.0.1
key_buffer              = 16K
max_allowed_packet      = 1M
thread_stack            = 64K
thread_cache_size       = 8
myisam-recover         = BACKUP
table_cache            = 20
query_cache_limit       = 1M
query_cache_size        = 2M
log_error = /var/log/mysql/error.log
expire_logs_days        = 10
max_binlog_size         = 100M
skip-innodb
default-storage-engine = MyISAM

[mysqldump]
quick
quote-names
max_allowed_packet      = 16M

[mysql]

[isamchk]
key_buffer              = 16M

!includedir /etc/mysql/conf.d/
END

	# Install the MariaDB packages
	check_install mysqld mariadb-server
	check_install mysql mariadb-client

	# all the related files.
	invoke-rc.d mysql stop
	rm -f /var/lib/mysql/ib*
	invoke-rc.d mysql start

	# Generating a new password for the root user.
	passwd=`get_password root@mysql`
	mysqladmin password "$passwd"
	cat > ~/.my.cnf <<END
[client]
user = root
password = $passwd
END
	chmod 600 ~/.my.cnf
}

function install_nginx {
	check_install nginx nginx
	
	# Need to increase the bucket size for Debian 5.
	if [ ! -d /etc/nginx ];
		then
		mkdir /etc/nginx
	fi
	if [ ! -d /etc/nginx/conf.d ];
		then
		mkdir /etc/nginx/conf.d
	fi

	sed -i s/'^worker_processes [0-9];'/'worker_processes 1;'/g /etc/nginx/nginx.conf
	sed -i s/'^user  nginx;'/'user  www-data;'/g /etc/nginx/nginx.conf
	invoke-rc.d nginx restart
	if [ ! -d /var/www ];
		then
		mkdir /var/www
	fi
	cat > /etc/nginx/proxy.conf <<EXND
proxy_connect_timeout 30s;
proxy_send_timeout   90;
proxy_read_timeout   90;
proxy_buffer_size    32k;
proxy_buffers     4 32k;
proxy_busy_buffers_size 64k;
proxy_redirect     off;
proxy_hide_header  Vary;
proxy_set_header   Accept-Encoding '';
proxy_set_header   Host   \$host;
proxy_set_header   Referer \$http_referer;
proxy_set_header   Cookie \$http_cookie;
proxy_set_header   X-Real-IP  \$remote_addr;
proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
EXND
}

function install_php {
	service mysql stop
	service nginx stop 

	apt-get -q -y --force-yes install php5-fpm
	sed -i s/'^; process.max = 128'/'process.max = 1'/g /etc/php5/fpm/php-fpm.conf
			sed -i \
				"s/memory_limit = 128M/memory_limit = 50M/" \
				/etc/php5/fpm/php.ini

	service php5-fpm stop
        apt-get -q -y --force-yes install php5-mysqlnd php5-gd php5-mcrypt php5-tidy php5-curl

	service mysql start
	service nginx start

}
	

function install_syslogd {
	# We just need a simple vanilla syslogd. Also there is no need to log to
	# so many files (waste of fd). Just dump them into
	# /var/log/(cron/mail/messages)
	check_install /usr/sbin/syslogd inetutils-syslogd
	invoke-rc.d inetutils-syslogd stop

	for file in /var/log/*.log /var/log/mail.* /var/log/debug /var/log/syslog
	do
		[ -f "$file" ] && rm -f "$file"
	done
	for dir in fsck news
	do
		[ -d "/var/log/$dir" ] && rm -rf "/var/log/$dir"
	done

	cat > /etc/syslog.conf <<END
*.*;mail.none;cron.none -/var/log/messages
cron.*		      -/var/log/cron
mail.*		      -/var/log/mail
END

	[ -d /etc/logrotate.d ] || mkdir -p /etc/logrotate.d
	cat > /etc/logrotate.d/inetutils-syslogd <<END
/var/log/cron
/var/log/mail
/var/log/messages {
   rotate 4
   weekly
   missingok
   notifempty
   compress
   sharedscripts
   postrotate
		/etc/init.d/inetutils-syslogd reload >/dev/null
   endscript
}
END

	invoke-rc.d inetutils-syslogd start
}


function install_vhost {
	check_install wget wget
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` vhost <hostname>"
	fi

	if [ ! -d /var/www ];
		then
		mkdir /var/www
fi
	mkdir "/var/www/$1"
	chown -R www-data "/var/www/$1"
		chmod -R 755 "/var/www/$1"

	  # Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server {
	server_name $1;
	root /var/www/$1;
	location / {
		index index.html index.htm;
	}
}
END
	invoke-rc.d nginx reload
	
	cat > "/var/www/$1/index.html" <<END
Hello world!
		----$2
END
	invoke-rc.d nginx reload	
}

function install_dhost {
	check_install wget wget
	if [ ! -d /var/www ];
		then
		mkdir /var/www
	fi
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` dhost <hostname>"
	fi
	mkdir "/var/www/$1"
 	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

# Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

	location / {
		try_files \$uri \$uri/ /index.php;
	}

	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}
	
		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      30d;
			}

		$al
	}
END


	invoke-rc.d nginx reload
	
	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi
}

function install_typecho {
	check_install wget wget
	if [ ! -d /var/www ];
		then
		mkdir /var/www
	fi
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` typecho <hostname>"
	fi

	# Downloading the typecho' latest and greatest distribution.
		mkdir /tmp/typecho.$$
	wget -O - "https://github.com/typecho/typecho/releases/download/v1.0-14.10.10-release/1.0.14.10.10.-release.tar.gz" | \
		tar zxf - -C /tmp/typecho.$$
	mv /tmp/typecho.$$/build/ "/var/www/$1"
	rm -rf /tmp/typecho.$$
 	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

	# Setting up the MySQL database
	dbname=`echo $1 | tr . _`
	userid=`get_domain_name $1`
	# MySQL userid cannot be more than 15 characters long
	userid="${dbname:0:15}"
	passwd=`get_password "$userid@mysql"`

	mysqladmin create "$dbname"
	echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
		mysql

	# Setting up Nginx mapping

	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
	{
		listen       80;

		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

	location / {
		try_files \$uri \$uri/ /index.php;
	}

	location ~ .*\.php(\/.*)*$ {
		#try_files \$uri =404;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      30d;
			}

		$al
	}
END

	invoke-rc.d nginx reload
		

	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

	
	cat >> "/root/$1.mysql.txt" <<END
[typycho_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END

	echo "mysql dataname:" $dbname
	echo "mysql username:" $userid
	echo "mysql passwd:" $passwd
}

function install_wordpress_en {
	check_install wget wget
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` wordpress <hostname>"
	fi

	# Downloading the WordPress' latest and greatest distribution.
	mkdir /tmp/wordpress.$$
	wget -O - http://wordpress.org/latest.tar.gz | \
		tar zxf - -C /tmp/wordpress.$$
	mv /tmp/wordpress.$$/wordpress "/var/www/$1"
	rm -rf /tmp/wordpress.$$
	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

	# Setting up the MySQL database
	dbname=`echo $1 | tr . _`
	userid=`get_domain_name $1`
	# MySQL userid cannot be more than 15 characters long
	userid="${dbname:0:15}"
	passwd=`get_password "$userid@mysql"`
	cp "/var/www/$1/wp-config-sample.php" "/var/www/$1/wp-config.php"
	sed -i "s/database_name_here/$dbname/; s/username_here/$userid/; s/password_here/$passwd/" \
		"/var/www/$1/wp-config.php"
	sed -i "31a define(\'WP_CACHE\', true);"  "/var/www/$1/wp-config.php"
	chown -R www-data "/var/www/$1"
	mysqladmin create "$dbname"
	echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
		mysql

	# Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

	location / {
	        try_files \$uri \$uri/ /index.php;
	}

	location ~ \.php$ {
	        try_files \$uri =404;
	        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	        include fastcgi_params;
	        fastcgi_pass unix:/var/run/php5-fpm.sock;
	}
	
		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      30d;
			}

		$al
	}
END

cat >> "/root/$1.mysql.txt" <<END
[wordpress_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END
	invoke-rc.d nginx reload
	
	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi
}


function install_carbonforum {
	check_install wget wget
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` carbon <hostname>"
	fi

	# Downloading the WordPress' latest and greatest distribution.
	mkdir /tmp/carbonforum.$$
	wget -O - https://github.com/lincanbin/Carbon-Forum/archive/5.0.1.tar.gz | \
		tar zxf - -C /tmp/carbonforum.$$
	mv /tmp/carbonforum.$$/Carbon-Forum-* "/var/www/$1"
	rm -rf /tmp/carbonforum.$$
	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

	# Setting up the MySQL database
	dbname=`echo $1 | tr . _`
	userid=`get_domain_name $1`
	# MySQL userid cannot be more than 15 characters long
	userid="${dbname:0:15}"
	passwd=`get_password "$userid@mysql"`
	mysqladmin create "$dbname"
	echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
		mysql

	# Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

	location / {
	        try_files \$uri \$uri/ /index.php;
	}

	location ~ \.php$ {
	        try_files \$uri =404;
	        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
	        include fastcgi_params;
	        fastcgi_pass unix:/var/run/php5-fpm.sock;
	}
	
		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      30d;
			}

	include /var/www/$1/nginx.conf;
		$al
	}	
END

cat >> "/root/$1.mysql.txt" <<END
[CarbonForum_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END
	invoke-rc.d nginx reload
	
	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

        echo "mysql dataname:" $dbname
        echo "mysql username:" $userid
        echo "mysql passwd:" $passwd
}

function install_rainloop {
	check_install wget wget
	check_install bsdtar bsdtar
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` rainloop <hostname>"
	fi

	# Downloading the Rainloop' latest and greatest distribution.
	mkdir /tmp/rainloop.$$
	wget -O - http://repository.rainloop.net/v2/webmail/rainloop-latest.zip | \
	bsdtar xf - -C /tmp/rainloop.$$
	mv /tmp/rainloop.$$ "/var/www/$1"
	rm -rf /tmp/rainloop.$$

	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

	#
	# Setting up the MySQL database
	dbname=`echo $1 | tr . _`
	userid=`get_domain_name $1`
	# MySQL userid cannot be more than 15 characters long
	userid="${dbname:0:15}"
	mysqladmin create "$dbname"
	echo "GRANT ALL PRIVILEGES ON \`$dbname\`.* TO \`$userid\`@localhost IDENTIFIED BY '$passwd';" | \
		mysql

	# Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
		{
		    listen       80;
		    server_name $1;
		    index index.html index.htm index.php default.html default.htm default.php;
		    root  /var/www/$1;

	location / {
		try_files \$uri \$uri/ /index.php;
	}

	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
				{
						expires      30d;
				}

		    location ~ .*\.(js|css)?$
				{
						expires      30d;
				}

		    $al
		}
END

cat >> "/root/$1.mysql.txt" <<END
[rainloop_myqsl]
dbname = $dbname
username = $userid
password = $passwd
END
	invoke-rc.d nginx reload

		ServerAdmin=""
		read -p "Please input Administrator Email Address:" ServerAdmin
		if [ "$ServerAdmin" == "" ]; then
		    echo "Administrator Email Address will set to webmaster@example.com!"
		    ServerAdmin="webmaster@example.com"
		else
		echo "==========================="
		echo Server Administrator Email="$ServerAdmin"
		echo "==========================="
		fi
}

function install_phpmyadmin {
	check_install wget wget
	if [ -z "$1" ]
	then
		die "Usage: `basename $0` phpmyadmin <hostname>"
	fi

	# Downloading the phpmyadmin latest and greatest distribution.
	mkdir /tmp/phpmyadmin.$$ /var/www/$1
	wget -O - https://files.phpmyadmin.net/phpMyAdmin/4.4.13.1/phpMyAdmin-4.4.13.1-all-languages.tar.gz | \
		tar zxf - -C /tmp/phpmyadmin.$$
	mv /tmp/phpmyadmin.$$/phpMyAdmin* "/var/www/$1/phpMyAdmin"
	rm -rf /tmp/phpmyadmin.$$
	chown -R www-data "/var/www/$1"
	chmod -R 755 "/var/www/$1"

		# Setting up Nginx mapping
	cat > "/etc/nginx/conf.d/$1.conf" <<END
server
	{
		listen       80;
		server_name $1;
		index index.html index.htm index.php default.html default.htm default.php;
		root  /var/www/$1;

	location / {
		try_files \$uri \$uri/ /index.php;
	}

	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}

		location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|ico)$
			{
				expires      30d;
			}

		location ~ .*\.(js|css)?$
			{
				expires      30d;
			}

		$al
	}
END

invoke-rc.d nginx reload
	
	ServerAdmin=""
	read -p "Please input Administrator Email Address:" ServerAdmin
	if [ "$ServerAdmin" == "" ]; then
		echo "Administrator Email Address will set to webmaster@example.com!"
		ServerAdmin="webmaster@example.com"
	else
	echo "==========================="
	echo Server Administrator Email="$ServerAdmin"
	echo "==========================="
	fi

cat ~/.my.cnf
}


function print_info {
	echo -n -e '\e[1;36m'
	echo -n $1
	echo -e '\e[0m'
}

function print_warn {
	echo -n -e '\e[1;33m'
	echo -n $1
	echo -e '\e[0m'
}

function check_version {
	cat /etc/issue | grep "Linux 5" 

if [ $? -ne 0 ]; then
	cat > /etc/init.d/vzquota  << EndFunc
#!/bin/sh
### BEGIN INIT INFO
# Provides:		     vzquota
# Required-Start:
# Required-Stop:
# Should-Start:		 $local_fs $syslog
# Should-Stop:		  $local_fs $syslog
# Default-Start:		0 1 2 3 4 5 6
# Default-Stop:
# Short-Description:		Fixed(?) vzquota init script
### END INIT INFO
EndFunc
fi
}


function remove_unneeded {
	# Some Debian have portmap installed. We don't need that.
	check_remove /sbin/portmap portmap

	# Remove rsyslogd, which allocates ~30MB privvmpages on an OpenVZ system,
	# which might make some low-end VPS inoperatable. We will do this even
	# before running apt-get update.
	check_remove /usr/sbin/rsyslogd rsyslog

	# Other packages that seem to be pretty common in standard OpenVZ
	# templates.
	check_remove /usr/sbin/apache2 'apache2*'
	check_remove /usr/sbin/named bind9
	check_remove /usr/sbin/smbd 'samba*'
	check_remove /usr/sbin/nscd nscd

	# Need to stop sendmail as removing the package does not seem to stop it.
	if [ -f /usr/lib/sm.bin/smtpd ]
	then
		invoke-rc.d sendmail stop
		check_remove /usr/lib/sm.bin/smtpd 'sendmail*'
	fi
}

function update_stable {
	apt-get -q -y update
	apt-get -q -y upgrade
	apt-get -q -y dist-upgrade
	apt-get -y install libc6 perl debconf dialog bsdutils
	apt-get -y install apt apt-utils dselect dpkg
	#~ apt-get -q -y upgrade
}

function update_nginx {
	apt-get -q -y update
	invoke-rc.d nginx stop
	apt-get -q -y remove nginx
	apt-get -q -y --force-yes install nginx
	if [ ! -d /etc/nginx ];
		then
		mkdir /etc/nginx
	fi
	if [ ! -d /etc/nginx/conf.d ];
		then
		mkdir /etc/nginx/conf.d
	fi
	cat > /etc/nginx/conf.d/actgod.conf <<END
client_max_body_size 20m;
server_names_hash_bucket_size 64;
END
	sed -i s/'^worker_processes [0-9];'/'worker_processes 1;'/g /etc/nginx/nginx.conf
	invoke-rc.d nginx restart
	if [ ! -d /var/www ];
		then
		mkdir /var/www
	fi
	cat > /etc/nginx/proxy.conf <<EXND
proxy_connect_timeout 30s;
proxy_send_timeout   90;
proxy_read_timeout   90;
proxy_buffer_size    32k;
proxy_buffers     4 32k;
proxy_busy_buffers_size 64k;
proxy_redirect     off;
proxy_hide_header  Vary;
proxy_set_header   Accept-Encoding '';
proxy_set_header   Host   \$host;
proxy_set_header   Referer \$http_referer;
proxy_set_header   Cookie \$http_cookie;
proxy_set_header   X-Real-IP  \$remote_addr;
proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
EXND
invoke-rc.d nginx restart
}

########################################################################
# START OF PROGRAM
########################################################################
export PATH=/bin:/usr/bin:/sbin:/usr/sbin

function tyinstall {
check_sanity
case "$1" in
exim4)
	install_exim4
	;;
mysql)
	install_mysql
	;;
nginx)
	install_nginx
	;;
php)
	install_php
	;;
system)
	check_version
	remove_unneeded
	update_stable
	install_dash
	install_syslogd
	;;
typecho)
	install_typecho $2
	;;
dhost)
	install_dhost $2
	;;
vhost)
	install_vhost $2
	;;
wordpress)
	install_wordpress_en $2
	;;
carbon)
	install_carbonforum $2
	;;
rainloop)
	install_rainloop $2
	;;
stable)
	check_version 
	remove_unneeded
	update_stable
	install_dash
	install_syslogd
	install_exim4
	install_mysql	
	install_nginx
	install_php
		;;
updatenginx)
	update_nginx
		;;
phpmyadmin)
	install_phpmyadmin $2
	;;
addnginx)
	sed -i s/'^worker_processes [0-9];'/'worker_processes iGodactgod;'/g /etc/nginx/nginx.conf
		sed -i s/iGodactgod/$2/g /etc/nginx/nginx.conf
		invoke-rc.d nginx restart
		;;
ssh)
	cat >> /etc/shells <<END
/sbin/nologin
END
useradd $2 -s /sbin/nologin
echo $2:$3 | chpasswd 
	;;
*)
	echo 'Usage:' `basename $0` '[option]'
	echo 'Available option:'
	for option in system exim4 mysql nginx php wordpress carbon rainloop ssh addnginx stable dhost vhost sshport phpmyadmin
	do
		echo '  -' $option
	done
	;;
esac
}
tyinstall $1 $2 $3 | tee -a /tmp/tylemp.log
