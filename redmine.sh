#/bin/sh

export LANG=en_US.UTF-8
echo "Redmine Installation"

# vars
rdm_version=$default_rdm_version
install_path="/usr/local/bin/redmine"
mysql_host="localhost"
mysql_port="3306"
mysql_dbname="redmine"
mysql_admin_user="root"
mysql_admin_password=""
mysql_redmine_user="root"
mysql_redmine_password=""

read -p "version (3.4.3) : " rdm_version
if [ "" = "$rdm_version" ]; then
  rdm_version="3.4.3";
fi

read -p "install path (/usr/local/bin/redmine) : " install_path
if [ "" = "$install_path" ]; then
  install_path="/usr/local/bin/redmine"
fi

read -p "mysql host (127.0.0.1) : " mysql_host
if [ "" = "$mysql_host" ]; then
  mysql_host="127.0.01"
fi

read -p "mysql port (3306) : " mysql_port
if [ "" = "$mysql_port" ]; then
  mysql_port="3306"
fi

read -p "mysql database name (redmine) : " mysql_dbname
if [ "" = "$mysql_dbname" ]; then
  mysql_dbname="redmine"
fi

read -p "mysql admin user (root) : " mysql_admin_user
if [ "" = "$mysql_admin_user" ]; then
  mysql_admin_user="root"
fi

read -p "mysql admin password () : " mysql_admin_password
if [ "" = "$mysql_admin_password" ]; then
  mysql_admin_password=""
fi

read -p "mysql redmine user (redmine) : " mysql_redmine_user
if [ "" = "$mysql_redmine_user" ]; then
  mysql_redmine_user="redmine"
fi

read -p "mysql redmine passsword (redmine) : " mysql_redmine_password
if [ "" = "$mysql_redmine_password" ]; then
  mysql_redmine_password="redmine"
fi 

# start to install
if [ ! -d "$install_path" ]; then
  mkdir $install_path
fi
cd $install_path

# download tarball
echo ""
echo "start to download redmine"
if [ ! -f "redmine.tar.gz" ]; then
  download_url="http://www.redmine.org/releases/redmine-$rdm_version.tar.gz"
  wget $download_url -O redmine.tar.gz
fi
echo "file downloaded to redmine.tar.gz"

tar -xf "redmine.tar.gz"
mv "redmine-$rdm_version" redmine
cd redmine

# setup config
echo "production:" >> config/database.yml
echo "  adapter: mysql2" >> config/database.yml
echo "  database: $mysql_dbname" >> config/database.yml
echo "  host: $mysql_host" >> config/database.yml
echo "  port: $mysql_port" >> config/database.yml
echo "  username: $mysql_redmine_user" >> config/database.yml
echo "  password: $mysql_redmine_password" >> config/database.yml
cd ..

# check ruby
command -v ruby
if [ $? -ne 0 ]; then
  echo "install ruby 2.4.2"
  if [ ! -f "ruby.tar.gz" ]; then
    wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.gz -O ruby.tar.gz
  fi
  tar -xf ruby.tar.gz
  mv ruby-2.4.2 ruby-src
  cd ruby-src
  ./configure   \
    --prefix=$install_path/ruby \
    --oldincludedir=$install_path/ruby/include \
    --datadir=$install_path/ruby/data \
    --htmldir=$install_path/ruby/doc/html \
    --dvidir=$install_path/ruby/doc/dvi \
    --pdfdir=$install_path/ruby/doc/pdf \
    --psdir=$install_path/ruby/doc/ps \
    --disable-install-doc 
  make
  make install
fi

exit

# setup mysql
echo ""
echo "setup database"

mysql \
  -h$mysql_host \
  -u$mysql_admin_user \
  -p$mysql_admin_password \
  -D $mysql_dbname \
  -P $mysql_port \
  -e "show tables;"

if [ $? -ne 0 ]; then
  echo "crate database $mysql_dbname "
  
  sql_query_create_db="CREATE DATABASE $mysql_dbname CHARACTER SET utf8;"
  sql_query_create_user="CREATE USER '$mysql_redmine_user'@'$mysql_host' IDENTIFIED BY '$mysql_redmine_password';"
  sql_query_grant_privileges="GRANT ALL PRIVILEGES ON $mysql_dbname.* TO '$mysql_redmine_user'@'$mysql_host';"

  mysql \
    -u$mysql_admin_user \
    -p$mysql_admin_password \
    -P $mysql_port \
    -e"$sql_query_create_db"

  mysql \
    -u$mysql_admin_user \
    -p$mysql_admin_password \
    -P $mysql_port \
    -e"$sql_query_create_user"

  mysql \
    -u$mysql_admin_user \
    -p$mysql_admin_password \
    -P $mysql_port \
    -e"$sql_query_grant_privileges"
fi

echo $download_url
echo $rdm_version

