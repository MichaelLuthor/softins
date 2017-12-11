#/bin/sh

export LANG=en_US.UTF-8
echo "Redmine Installation"

# vars
rdm_version="3.4.3"
install_path="/usr/local/bin/redmine"
mysql_host="localhost"
mysql_port="3306"
mysql_dbname="redmine"
mysql_admin_user="root"
mysql_admin_password=""
mysql_redmine_user="redmine"
mysql_redmine_password="redmine"

old_env_path=$PATH

:<<!
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
!

# setup database
mysql_option="-h$mysql_host -u$mysql_admin_user -P $mysql_port"
if [ "$mysql_admin_password" ]; then
  mysql_option="$mysql_option -p$mysql_admin_password"
fi

mysql $mysql_option -D $mysql_dbname -e "show tables;"
if [ $? -ne 0 ]; then
  sql_query="CREATE DATABASE $mysql_dbname CHARACTER SET utf8;"
  sql_query="$sql_query CREATE USER '$mysql_redmine_user'@'$mysql_host' IDENTIFIED BY '$mysql_redmine_password';"
  sql_query="$sql_query GRANT ALL PRIVILEGES ON $mysql_dbname.* TO '$mysql_redmine_user'@'$mysql_host';"

  mysql $mysql_option -e"$sql_query"
fi


# setup workspace
useradd redmine
if [ ! -d "$install_path" ]; then
  mkdir $install_path
  mkdir "$install_path/install"
fi
cd $install_path


# check ruby or install
ruby_path=""
command -v ruby
if [ $? -ne 0 ]; then
  ruby_path="$install_path/ruby/bin"

  cd install
  if [ ! -f "ruby.tar.gz" ]; then
    wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.gz -O ruby.tar.gz
  fi
  if [ ! -d "../ruby" ]; then
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

  export PATH=$PATH:$install_path/ruby/bin/
  
  #cd ext/zlib
  #yum install -y zlib zlib-devel
  #ruby extconf.rb
  #sed -i "s/\$(top_srcdir)/\/usr\/local\/bin\/redmine\/install\/ruby-src/g" Makefile
  #make 
  #make install
  
  #cd ext/openssl
  #yum install -y openssl openssl-devel
  #ruby extconf.rb
  #sed -i "s/\$(top_srcdir)/\/usr\/local\/bin\/redmine\/install\/ruby-src/g" Makefile
  #make
  #make install
  
  #cd ../..
  
  cd ..
fi

cd install
# download tarball
if [ ! -f "redmine.tar.gz" ]; then
  download_url="http://www.redmine.org/releases/redmine-$rdm_version.tar.gz"
  wget $download_url -O redmine.tar.gz
fi

if [ ! -d "../redmine" ]; then
  tar -xf "redmine.tar.gz"
  mv "redmine-$rdm_version" redmine
  mv redmine ../
fi
cd ../


# setup
cd redmine
#echo "production:" >> config/database.yml
#echo "  adapter: mysql2" >> config/database.yml
#echo "  database: $mysql_dbname" >> config/database.yml
#echo "  host: $mysql_host" >> config/database.yml
#echo "  port: $mysql_port" >> config/database.yml
#echo "  username: $mysql_redmine_user" >> config/database.yml
#echo "  password: $mysql_redmine_password" >> config/database.yml

#gem install bundler
#yum install -y mysql-devel
#gem install mysql2 -v '0.4.10'
#yum install -y ImageMagick ImageMagick-devel
#gem install rmagick -v '2.16.0'

#bundle install --without development test
#bundle exec rake generate_secret_token
#RAILS_ENV=production bundle exec rake db:migrate
#RAILS_ENV=production bundle exec rake redmine:load_default_data

#mkdir -p tmp tmp/pdf public/plugin_assets
#chown -R redmine:redmine files log tmp public/plugin_assets
#chmod -R 755 files log tmp public/plugin_assets

# create tools
echo "#/bin/bash" >> test.sh
if [ $ruby_path ]; then
  echo "old_env_path=\$PATH"
  echo "export PATH=\$PATH:$ruby_path" >> test.sh
fi
echo "bundle exec rails server webrick -e production" >> test.sh
if [ $ruby_path ]; then
  echo "export PATH=\$old_env_path" >> test.sh
fi
chmod u+x test.sh

# Resotre old env value
export PATH=$old_env_path
