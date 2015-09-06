alias vhost_edit='echo "vi /private/etc/apache2/extra/httpd-vhosts.conf";vi /private/etc/apache2/extra/httpd-vhosts.conf'

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
      if [ $dbexists -eq 1 ]; then
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

function getVhostLocation() {
   if [  -z $1  ]; then
     echo ;
     echo 'arguments missing';
     echo 'getVhostLocation <<url>>';
     echo 'please try again';
  fi
  #
  vhost_file_location='/etc/apache2/extra/httpd-vhosts.conf';
  # add ; to EOL
  string=$(cat ${vhost_file_location} | sed -e"s/$/;/g");
  #
  # split vhosts by |
  delimter='< *VirtualHost *\*:80 *>'
  string=$(echo ${string} | sed -e"s/${delimter}/|/g");
  #
  # cycle through the delimitered sections
  OIFS=$IFS;
  IFS="|";
  Array=($string);
  for ((i=0; i<${#Array[@]}; ++i)); do
          grepped=$( echo ${Array[$i]} | grep "$url" );
          if [ ${#grepped} -gt 0 ]; then
              myVhostDetails=$grepped;
          fi
  done
  IFS=$OIFS;
  #
  # cycle through my vhost sections
  OIFS=$IFS;
  IFS=";";
  Array=($myVhostDetails);
  for ((i=0; i<${#Array[@]}; ++i)); do
          grepped=$( echo ${Array[$i]} | grep 'DocumentRoot' );
          if [ ${#grepped} -gt 0 ]; then
              documentRoot=$(echo ${grepped} | sed -e"s/DocumentRoot//g"| sed -e"s/ *//g");
          fi
  done
  IFS=$OIFS;
  #
  echo $documentRoot;
}

function update_localxml() {
   vhost_file_location='/etc/apache2/extra/httpd-vhosts.conf'
   if [  -z $1  ] || [  -z $2 ] ; then
     echo ;
     echo 'arguments missing'
     echo 'update_localxml <<db>> <<url>>'
     echo 'please try again'
   else
     database=$1
     url=$2
     grepped=$(grep -B 7 -A 8  ${url} $vhost_file_location)
     location=getVhostLocation ${url}
     sed -i "s/<dbname>.*<\/dbname>/<dbname><\!\[CDATA\[${database}\]\]><\/dbname>/g" ${location}/app/etc/local.xml
  fi
}

function mkvhost() {
    # file locations
    httpdvhosts='/etc/apache2/extra/httpd-vhosts.conf'
    hostsfile='/etc/hosts'
    setupfile='~/Documents/local_setup_files/vhost_template.txt'
    if [  -z $1  ] || [  -z $2 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'mkvhost <<sub folder>> <<url>>'
      echo 'please try again'
    else
      subfolder=$1;
      url=$2;
      echo "------- updating hosts file -------"
      echo '127.0.0.1 '$url >> ${hostsfile};
      echo "------- updating vhosts file -------"
      vhostdefault=$(<${setupfile});
      vhostdetails=$( echo ${vhostdefault} | sed -e"s/myurl/${url}/" | sed -e"s/subfolder/${subfolder}/" );
      echo  $vhostdetails >> ${httpdvhosts};
      sudo apachectl restart;
    fi  
}

function setuplocal() {
	if [  -z $1  ] || [  -z $2 ] || [  -z $3 ] ; then
      echo ;
      echo 'arguments missing'
      echo 'setuplocal <<sub folder>> <<file>> <<url>> or setuplocal <<sub folder>> <<file>> <<url>> <<db>>'
      echo 'please try again'
    else	
      subfolder=$1;
	  file=$2;
      url=$3;
      ### import database ###
      fileextension="${file##*.}"; # last fil extension if example.sql.tar.gz it returns gz if example.sql returns sql
      # if sql file
      if [[ $fileextension == "sql" ]]; then
      	$db=${file%.sql};
      	sql2mysql $file $url $db;
      # if ****.gz file
      elif [[ $fileextension == "gz" ]]; then
      	prevfileextension=${${file%.gz}##*.}; #previous file extension; 
      	# if tar.gz file
      	if [[ prevfileextension == "tar" ]]; then
	      	$db=${file%.tar.gz};
      		tar2mysql $file $url $db;
      	fi
      else
 		echo "error: unrecognised file format";
 		exit;
      fi
      if [[ getVhostLocation ${url}!="" ]]; then
      	mkvhost $subfolder $url;
  	  fi;
      echo "------- updating local.xml -------";
      update_localxml ${db} ${url};
      echo "------- updating local.xml -------";
      cd getVhostLocation ${url};
      cp ~/Documents/local_setup_files/.htaccess . 
      echo "------- flushing cache -------";
      n98-magerun.phar cache:flush;
      echo "------- reindexing -------";
      n98-magerun.phar index:reindex:all;
    fi
}