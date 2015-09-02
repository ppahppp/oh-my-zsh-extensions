function tar2mysql() {
  if [  -z $1  ] || [  -z $2 ] ; then
    echo ;
    echo 'arguments missing'
    echo 'tar2mysql <<file>> <<url>> or tar2mysql <<file>> <<url>> <<db>>'
    echo 'please try again'
  else
    file=$1
    url=$2
    db=$3
    echo $db
    echo '-->uncompressing file'
    tar -xzvf $file &&
    sql2mysql ${file%.tar.gz}.sql $url $db 
    echo '-->removing sql'
    rm ${file} # $file redefined in sql2mysql() 
  fi
}

function sql2mysql() {
    user=root
    password=root
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'sql2mysql <<file>> <<url>>  or sql2mysql <<file>> <<url>> <<db>>'
      echo 'please try again'
    else
      file=$1;
      url=$2;
      if [  -z $3  ]; then
        db=${${file%.sql}##*/}
      else
        db=$3
      fi
        dbexists=$(mysql -u${user} -p${password} --batch --skip-column-names -e "SHOW DATABASES LIKE '"${db}"';" | grep "${db}" > /dev/null; echo "$?")
        echo $dbexists
      if [ $dbexists -eq 1 ];then
        echo '-->creating db'
        mysql -u${user} -p${password} -e"create database ${db}" 
        echo '-->impoting db'
        mysql -u${user} -p${password} $db < $file 
        echo '-->updating db'
        table='core_config_data' 
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/unsecure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
        cmd="update ${db}.${table} set value='http://${url}/' where path='web/secure/base_url';"
        mysql -u${user} -p${password} -e"${cmd}"
      else
        echo "error: database name" ${db} " used"
      fi
    fi
}

function update_localxml(){
   vhost_file_location='/etc/apache2/extra/httpd-vhosts.conf'
   if [  -z $1  ] || [  -z $2 ] ; then
     echo ;
     echo 'arguments missing'
     echo 'update_localxml_database <<database_name>> <<local_url>>'
     echo 'please try again'
   else
     database=$1
     url=$2
     grepped=$(grep -B 7 -A 8  ${url} $vhost_file_location)

# egrep "ServerName|DocumentRoot" /etc/apache2/extra/httpd-vhosts.conf


#echo grepped=$(echo $grepped |sed -e 's/<VirtualHost(\n|\r|.)*<\/VirtualHost/\1/')  #awk -F'VirtualHost|VirtualHost' '{print $2}')
     grepped=$(echo $grepped |sed -e 's/Virtual/hbewfjhwe/'|cat)
     echo $grepped 

     location=$(echo $grepped | grep DocumentRoot | cut -f2 -d'"'  ) 
    # echo 'location: '${location}
    # sed -i "s/<dbname>.*<\/dbname>/<dbname><\!\[CDATA\[${database}\]\]><\/dbname>/g" ${location}/app/etc/local.xml
  fi
}

function mkvhost() {
    # file locations
    httpdvhosts='/etc/apache2/extra/httpd-vhosts.conf'
    hostsfile='/etc/hosts'
    setupfile='/Users/Paul/Documents/local_setup_files/vhost_template.txt'
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'mkvhost <<sub folder>> <<url>>'
      echo 'please try again'
    else
      subfolder=$1;
      url=$2;
      echo '127.0.0.1 '$url >> ${hostsfile};
      vhostdefault=$(<${setupfile});
      vhostdetails=$( echo ${vhostdefault} | sed -e"s/myurl/${url}/" | sed -e"s/subfolder/${subfolder}/" );
      echo  $vhostdetails >> ${httpdvhosts};
    fi  
}

alias vhost_edit='echo "vi /private/etc/apache2/extra/httpd-vhosts.conf";vi /private/etc/apache2/extra/httpd-vhosts.conf'
