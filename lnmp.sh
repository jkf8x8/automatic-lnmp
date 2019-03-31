#! /bin/sh
#更新yum镜像
echo '是否换为国内镜像(y/n)'
read action
while( [ $action != 'y' ] && [ $action != 'n' ])
do
  echo '看清楚了兄弟'
  echo '是否换为国内镜像(y/n)'
  read action
done

if [ $action = 'y' ]
then
 mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
 curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
 yum -y update&& echo "资源更新完毕"
fi

# make nginx.repo ########################
if [ -e '/etc/yum.repos.d/nginx.repo' ]
then
  echo 'nginx.repo is already'
  exit
else
  cd /etc/yum.repos.d
cat >nginx.repo <<EOF
[nginx]
name=nginx 
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
fi

# make mariadb.repo #######################
if [ -e '/etc/yum.repos.d/MariaDB.repo' ]
then 
 ehco 'MariaDB.repo is already'
 exit
else
 cd /etc/yum.repos.d
cat > MariaDB.repo <<EOF
[mariadb]
name = MariaDB
#官方源
#baseurl = http://yum.mariadb.org/10.3/centos7-amd64
#gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
#阿里源
baseurl=http://mirrors.aliyun.com/mariadb/yum/10.3/centos7-amd64
gpgkey= http://mirrors.aliyun.com/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
fi

yum -y clean all && echo "清除yum缓存"

yum makecache && echo "生成yum缓存"



# install nginx
echo '安装nginx'
yum -y install nginx
echo 'nginx完毕'
# configure nginx
echo '配置nginx支持 php'
mv /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.bak
cat >default.conf <<EOF
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm index.php;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location ~ \.php\$ {
        root           /usr/share/nginx/html;
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }
}
EOF



# install mariadb
yum -y install MariaDB-server MariaDB-client
#install php7.3
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm 
yum -y install epel-release yum-utils
yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php73
yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json

# boot
systemctl enable nginx
systemctl enable php-fmp
systemctl enable mariadb

# close firewalld
systemctl stop firewalld
systemctl disable mariadb

#mysql 
#mysql_secure_installation