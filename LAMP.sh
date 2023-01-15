#!/bin/bash
#by LIKE~  qq2754818548
#github：https://github.com/zyllk
#-------------------------------------------------------------------------------
#                   Apache2.4
#apache path
H_FILES_DIR=httpd-2.4.54
H_FILES=httpd-2.4.54.tar.gz
H_URL=https://mirrors.cnnic.cn/apache/httpd
H_PREFIX=/usr/local/apache24
#apr path
P_FILES_DIR=apr-1.7.0
P_FILES=apr-1.7.0.tar.gz    
P_URL=https://mirrors.cnnic.cn/apache/apr
P_PREFIX=/usr/local/apache24/apr
#apr-util path
PU_FILES_DIR=apr-util-1.6.1
PU_FILES=apr-util-1.6.1.tar.gz
PU_URL=https://mirrors.cnnic.cn/apache/apr
PU_PREFIX=/usr/local/apache24/apr-util
#pcre path
PC_FILES_DIR=pcre-8.42
PC_FILES=pcre-8.42.tar.bz2
PC_URL=https://mirrors.aliyun.com/blfs/conglomeration/pcre
PC_PREFIX=/usr/local/apache24/pcre
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
#                  PHP7.2
#php path
PHP_FILES_DIR=php-7.2.14
PHP_FILES=php-7.2.14.tar.gz
PHP_URL=https://www.php.net/distributions/
PHP_PREFIX=/usr/local/php72
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
#                  Mysql5.7
#mysql path
MY_FILES_DIR=mysql-5.7.38
MY_FILES=mysql-5.7.38.tar.gz
MY_URL=https://mirrors.cnnic.cn/mysql/downloads/MySQL-5.7
MY_PREFIX=/usr/local/mysql57
#mysql-boost path
MB_FILES_DIR=boost_1_59_0
MB_FILES=boost_1_59_0.tar.gz
MB_URL=https://sourceforge.net/projects/boost/files/boost/1.59.0
MB_PREFIX=/usr/local/mysql-boost
#--------------------------------------------------------------------------------


#--------------------------------------------------------------------------------
#tools

#my.cnf path
touch ~/my.cnf
cat > ~/my.cnf<<EOF
[mysqld]
basedir=$MY_PREFIX
datadir=$MY_PREFIX/data
port=3306
server_id=1
socket=/tmp/mysql.sock
pid-file=$MY_PREFIX/data/mysql.pid
log-error=$MY_PREFIX/data/mysqld.err
log-bin=$MY_PREFIX/data/mysql-bin
relay_log=$MY_PREFIX/data/mysql-relay-bin
character-set-server=utf8
collation-server=utf8_general_ci
user=mysql
expire_logs_days=7
max_connections = 500
[client]
socket=/tmp/mysql.sock
EOF
#--------------------------------------------------------------------------------
function show_check() {
    #检测本机网络网络
    ping -c 2 www.baidu.com > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo '当前网络可达，可以进行安装！'
        sleep 2
        service iptables stop   > /dev/null 2>&1
        systemctl stop firewalld > /dev/null 2>&1
        systemctl disable firewalld  > /dev/null 2>&1

    else
        echo '网络不可达，请检查网络！'
        return
    fi
}

function install_1() {
    clear
    for i in {8..1}
        do        
            echo -n "准备执行安装 $i !!"
            sleep 1
            clear
        done
        echo "安装工具包..."
        sleep 1
        yum -y install make gcc gcc-c++ openssl openssl-devel expat-devel wget cmake ncurses ncurses-devel 
        echo -e "\033[32m安装依赖：$P_FILES_DIR\033[0m"
        sleep 1

        cd ~/ && wget -c $P_URL/$P_FILES && tar -zxf $P_FILES && cd $P_FILES_DIR ;./configure --prefix=$P_PREFIX

        if [ $? -eq 0 ];then
            make && make install
            cd ~/ && rm -rf $P_FILES && rm -rf $P_FILES_DIR
            echo -e "\033[32m $P_FILES_DIR 依赖安装成功！\033[0m"   
        else    
            cd ~/ && rm -rf $P_FILES && rm -rf $P_FILES_DIR && rm -rf my.cnf 
            echo -e "\033[31mERROR: $P_FILES_DIR 依赖安装失败！\033[0m"
            return
        fi
            echo -e "\033[32m安装依赖：$PU_FILES_DIR\033[0m"
            sleep 1
            cd ~/ && wget -c $PU_URL/$PU_FILES && tar -zxf $PU_FILES && cd $PU_FILES_DIR ;./configure --prefix=$PU_PREFIX --with-apr=$P_PREFIX/bin/apr-1-config
            if [ $? -eq 0 ];then
                make && make install
                cd ~/ && rm -rf $PU_FILES && rm -rf $PU_FILES_DIR
                echo -e "\033[32m $PU_FILES_DIR 依赖安装成功！\033[0m"
            else
                cd ~/ && rm -rf $PU_FILES && rm -rf $PU_FILES_DIR && rm -rf my.cnf 
                echo -e "\033[31mERROR: $PU_FILES_DIR 依赖安装失败！\033[0m"
                return
            fi 
                echo -e "\033[32m安装依赖：$PC_FILES_DIR\033[0m"
                sleep 1
                cd ~/ && wget -c $PC_URL/$PC_FILES && tar -jxf $PC_FILES && cd $PC_FILES_DIR ;./configure --prefix=$PC_PREFIX
                if [ $? -eq 0 ];then
                    make && make install
                    cd ~/ && rm -rf $PC_FILES && rm -rf $PC_FILES_DIR
                    echo -e "\033[32m $PC_FILES_DIR 依赖安装成功！\033[0m" 
                else
                    cd ~/ && rm -rf $PC_FILES && rm -rf $PC_FILES_DIR && rm -rf my.cnf
                    echo -e "\033[31mERROR: $PC_FILES_DIR 依赖安装失败！\033[0m"
                    return
                fi 
                    echo -e "\033[32m安装：$H_FILES_DIR\033[0m"
                    sleep 1
                    cd ~/ && wget -c $H_URL/$H_FILES && tar -zxf $H_FILES && cd $H_FILES_DIR ; ./configure --prefix=$H_PREFIX --enable-so --enable-rewrite --enable-ssl --with-apr=$P_PREFIX --with-apr-util=$PU_PREFIX --with-pcre=$PC_PREFIX/bin/pcre-config --enable-modules=most --enable-mpms-shared=all --with-mpm=event
                    if [ $? -eq 0 ];then
                        make && make install
                        cd ~/ && rm -rf $H_FILES && rm -rf $H_FILES_DIR 
                        sed -i '256c    DirectoryIndex index.html index.php' $H_PREFIX/conf/httpd.conf
                        echo -e "<FilesMatch \.php$>\n   SetHandler application/x-httpd-php\n</FilesMatch>" >> $H_PREFIX/conf/httpd.conf
                        echo "export PATH=\$PATH:$H_PREFIX/bin" >> /etc/profile && source /etc/profile
                        echo -e "\033[32m $H_FILES_DIR 服务安装成功！\033[0m" 
                        sleep 1
                        echo "ServerName localhost:80" >>$H_PREFIX/conf/httpd.conf
                        $H_PREFIX/bin/apachectl start 
                        echo -e "\033[32m $H_FILES_DIR 服务启动成功！\033[0m" 
                    else
                        cd ~/ && rm -rf $H_FILES && rm -rf $H_FILES_DIR && rm -rf my.cnf
                        echo -e "\033[31mERROR: $H_FILES_DIR安装失败！\033[0m" 
                        return
                    fi
                        echo -e "\033[32m配置依赖：$MB_FILES_DIR\033[0m"
                        sleep 1
                        groupadd mysql && useradd -M -s /sbin/nologin -g mysql mysql && mkdir -p $MB_PREFIX/
                        cd ~/ && wget -c $MB_URL/$MB_FILES && tar -zxf $MB_FILES && mv -i $MB_FILES_DIR $MB_PREFIX  ; yum install -y cmake make gcc gcc-c++ bison ncurses ncurses-devel
                        yum -y remove mysql mariadb-* && yum -y remove boost-*
                        rm -rf $MB_FILES
                        wget https://github.com/thkukuk/rpcsvc-proto/releases/download/v1.4.1/rpcsvc-proto-1.4.1.tar.xz && xz -d rpcsvc-proto-1.4.1.tar.xz && tar -xvf rpcsvc-proto-1.4.1.tar
                        cd rpcsvc-proto-1.4.1 
                        ./configure
                        make
                        make install
                        echo -e "\033[32m依赖：$MB_FILES_DIR配置成功！\033[0m"
                        sleep 1
                        echo -e "\033[32m安装：$MY_FILES_DIR\033[0m"
                        yum install -y libtirpc libtirpc-devel
                        mkdir -p $MY_PREFIX && mkdir -p $MY_PREFIX/data
                        chown -R mysql:mysql $MY_PREFIX && chown -R mysql:mysql $MY_PREFIX/data
                        cd ~/ && wget -c $MY_URL/$MY_FILES && tar -zxf $MY_FILES && cd $MY_FILES_DIR ;cmake -DCMAKE_INSTALL_PREFIX=$MY_PREFIX -DMYSQL_DATADIR=$MY_PREFIX/data -DSYSCONFDIR=/etc -DMYSQL_TCP_PORT=3306 -DDEFAULT_CHARSET=utf-8 -DDEFAULT_COLLATION=utf-8_general_ci -DWITH_BOOST=$MB_PREFIX
                        if [ $? -eq 0 ];then
                            cpus=`grep processor /proc/cpuinfo | wc -l`
                            make -j $cpus && make install
                            echo "export PATH=\$PATH:$MY_PREFIX/bin" >> /etc/profile && source /etc/profile && touch /etc/my.cnf
                            cat  ~/my.cnf > /etc/my.cnf
                            chown -R mysql:mysql /etc/my.cnf
                            cp -i $MY_PREFIX/support-files/mysql.server  /etc/init.d/ && systemctl  daemon-reload
                            mysqld --initialize-insecure  --user=mysql  --explicit_defaults_for_timestamp=1 --basedir=$MY_PREFIX --datadir=$MY_PREFIX/data
                            if [ $? -eq 0 ];then
                                echo "设置启动"
                                cd ~/ && rm -rf my.cnf && rm -rf $MY_FILES && rm -rf $MY_FILES_DIR
                                systemctl  start  mysql.server && systemctl enable  mysql.server
                                clear
                                if [ $? -eq 0 ];then
                                    clear
                                    echo -e "\033[32mmysql启动成功！\033[0m"
                                else
                                    echo -e "\033[31mERROR: $MY_FILES_DIR 服务启动失败！，请检查错误日志：$MY_PREFIX/data/mysqld.err\033[0m"
                                    return
                                fi
                            else
                                rm -rf $MY_PREFIX/data
                                mysqld --initialize-insecure  --user=mysql  --explicit_defaults_for_timestamp=1 --basedir=$MY_PREFIX --datadir=$MY_PREFIX/data
                                echo "设置启动"
                                cd ~/ && rm -rf my.cnf && rm -rf $MY_FILES && rm -rf $MY_FILES_DIR
                                systemctl  start  mysql.server && systemctl enable  mysql.server
                                if [ $? -eq 0 ];then
                                    clear
                                    echo -e "\033[32mmysql启动成功！\033[0m"
                                    echo -e '\033[32mMYSQL无密码，使用set password for "root"@"localhost"=password("密码");来设置密码\033[0m'
                                else
                                    echo -e "\033[31mERROR: $MY_FILES_DIR 服务启动失败！，请检查错误日志：$MY_PREFIX/data/mysqld.err\033[0m"
                                    return
                                fi
                            fi
                        else
                            echo -e "\033[31mERROR: $MY_FILES_DIR 服务安装失败！\033[0m"  
                            cd ~/ && rm -rf $MY_FILES && rm -rf $MY_FILES_DIR && rm -rf /etc/my.cnf
							return
                        fi
                            yum -y install libxml2 libxml2-devel libpng libpng-devel freetype-devel db4-devel libjpeg-devel curl-devel
                            echo -e "\033[32安装$PHP_FILES_DIR！\033[0m"
                            sleep 1
                            cd ~/ &&  wget $PHP_URL/$PHP_FILES && tar -zxf $PHP_FILES && cd $PHP_FILES_DIR ;./configure --prefix=$PHP_PREFIX --with-apxs2=$H_PREFIX/bin/apxs --with-config-file-path=$PHP_PREFIX/etc --with-mysql=$MY_PREFIX --with-mysqli --enable-ftp --enable-zip --with-jpeg-dir --with-png-dir --with-zlib-dir --with-gd --enable-exif --with-openssl --enable-dbase --with-curl --enable-calendar --enable-mbstring --enable-magic-quotes
                            if [ $? -eq 0 ];then
                                make && make install
                                cd ~/$PHP_FILES_DIR && cp -i php.ini-production $PHP_PREFIX/etc/php.ini
                                echo "export PATH=\$PATH:$PHP_PREFIX/bin" >> /etc/profile && source /etc/profile
                                cd ~ && rm -rf $PHP_FILES && rm -rf $PHP_FILES_DIR
                                apachectl restart
                                echo -e "\033[32m$PHP_FILES_DIR 安装成功！\033[0m"
                                echo -e "<?php\nphpinfo();\n?>" > $H_PREFIX/htdocs/info.php
                                clear
                                echo -e "+-------------------------------------------------------------------------------------+"
                                echo -e "\033[32m| Apache:$H_FILES_DIR ok! 安装路径:$H_PREFIX                                                     \033[0m"
                                echo -e "\033[32m| Mysql:$MY_FILES_DIR ok! 安装路径:$MY_PREFIX                                       \033[0m"
                                echo -e '\033[32m  MYSQL无密码使用: set password for "root"@"localhost"=password("密码");来设置密码\033[0m'
                                echo -e "\033[32m| PHP :$PHP_FILES_DIR ok! 安装路径:$PHP_PREFIX      \033[0m"
                                echo -e "\033[32m| 请访问地址测试：http://${ip}/info.php                   \033[0m"
                                echo -e "+--------------------------------------------------------------------------------------+"
                                return
                            else
                                cd ~ && rm -rf $PHP_FILES && rm -rf $PHP_FILES_DIR
                                echo -e "\033[31mERROR: $PHP_FILES_DIR 安装失败！\033[0m"
                                return
                            fi
}

function uninstall() {
read -ep "确定删除吗 y/n"unin
case $unin in 
    [yY])
        echo '删除！'
        sleep 1
        echo "停止！"
        apachectl stop && mysqladmin -u root shutdown 
        sed -i '$d' /etc/profile && sed -i '$d' /etc/profile && sed -i '$d' /etc/profile && source /etc/profile && rm -rf  /etc/init.d/mysql.server && rm -rf $MY_PREFIX && rm -rf $H_PREFIX && rm -rf $PHP_PREFIX && rm -rf $MB_PREFIX
        if [ $? -eq 0 ];then
            echo "删除成功！"
            return
        else
            echo "删除失败，请手动删除路径"
            echo "Apache:$H_PREFIX"
            echo "PHP:$PHP_PREFIX"
            echo "Mysql:$MY_PREFIX"
            echo "boost:$MB_PREFIX"
            return
        fi      
        ;;
    [nN])
        echo '退出程序!'
        return
        ;;
    *)
        echo '退出程序！'
        return
esac
}

export ip=$(ifconfig | sed -n 2p | awk '{print $2}')
#判断用户输入
clear
echo -e "+-------------------------------------------------------------------------------------+"
echo -e "\033[32m| 主机名: $HOSTNAME                                                     \033[0m"
echo -e "\033[32m| 系统: `cat /etc/centos-release`                                       \033[0m"
echo -e "\033[32m| 内核: `uname -r`                                                      \033[0m"
echo -e "\033[32m| CPU :`cat /proc/cpuinfo | grep "model name"|cut -d: -f2|head -1`      \033[0m"
echo -e "\033[32m| 内存: `free -m |grep Mem|tr -s " "|cut -d" " -f2` MB                  \033[0m"
echo -e "+--------------------------------------------------------------------------------------+"
echo -e "\033[32m LAMP一键编译安装\033[0m"
echo -e "\033[32m 1.Apache2.4+php7.2+Mysql5.7\033[0m"
echo -e "\033[32m 2.删除编译的LAMP环境\033[0m"
read -ep "请输入编号进行执行：" sss


if [[ "$sss" -eq "1" ]];then
    show_check
    install_1
elif [[ "$sss" -eq "2" ]];then
	uninstall
else
    echo -e "\033[31mERROR: 你输入错了！\033[0m" 
	return
fi
