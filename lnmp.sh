#! /bin/sh

# make nginx.repo ########################
if [ -e '/etc/yum.repos.d/nginx.repo' ]
then
  echo 'nginx.repo is already'
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

yum -y clean all && echo "yum clean"

yum makecache && echo "huan cun success"

# install nginx
yum -y install nginx
# install mariadb
yum -y install MariaDB-server MariaDB-client
#install php7.3
yum -y install epel-release yum-utils
yum-config-manager --enable remi-php73
yum -y install php php-cli php-fpm php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json

# boot
systemctl enable nginx
systemctl enable php-fmp
systemctl enable mariadb

# close firewalld
systemctl stop firewalld
systemctl disable mariadb