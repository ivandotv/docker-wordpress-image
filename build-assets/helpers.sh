#!/bin/bash

   function change_permissions () {

       echo "change permissions on directories"

       find "$WORDPRESS_DIRECTORY" -type d -not -path "*/node_modules/*" -not -path "*/node_modules" \
       -not -path "*/bower_components/*" -not -path "*/bower_components" \
       -print0 \
       | xargs -0 chmod 775

       echo "change permissions on files"
       #change permission on files
       find "$WORDPRESS_DIRECTORY" -type f -not -path "*/node_modules/*" \
       -not -path "*/bower_components/*"  \
       -print0 \
       | xargs -0 chmod 664

   }
    
  function  change_ownership () {

        #user_id=${1:-1000}    

        echo "change ownership on directories"

        find "$WORDPRESS_DIRECTORY" -type d -not -path "*/node_modules/*" -not -path "*/node_modules" \
        -not -path "*/bower_components/*" -not -path "*/bower_components" \
        -print0 \
        | xargs -0 chown "$1":www-data
        
        
        echo "change ownership on files"
        find "$WORDPRESS_DIRECTORY" -type f -not -path "*/node_modules/*" \
        -not -path "*/bower_components/*"  \
        -print0 \
        | xargs -0 chown "$1":www-data
  }

   # optionally run config scripts
  function  run_config_script(){

        custom_setup=$1
        cache_dir=$2
        script=$3;
        force_run=$4
        is_php=$5
        full_script_path=${custom_setup}/${script}
        script_hash_file=${cache_dir}/${script}.hash
        current_hash=''
        previous_hash=''
        hash_match='no'

        # if [[ -f "$full_script_path" || 'setup.yml' == "$script" ]]; then
        if [[ -f "$full_script_path" ]]; then

            if [[ 'setup.yml' != "$script" ]];then
                chmod +x $full_script_path
            fi

            current_hash=$(md5sum $full_script_path);
            
            if [[ -f "$script_hash_file" ]];then

                previous_hash=$(cat "$script_hash_file")

                if [[ "$current_hash" == "$previous_hash" ]];then

                    hash_match='yes'

                fi
            fi


            if [[  "$force_run" == 'true' || "$hash_match" == 'no' ]];then

                echo "running script: $full_script_path"

                if [[ "$is_php" == 'php' ]]; then

                    if php /etc/wp-setup.php $full_script_path;then
                        echo "$current_hash" > $script_hash_file
                    fi

                else

                    if  $full_script_path;then
                        echo "$current_hash" > $script_hash_file
                    fi

                fi

            else

                echo "skipped script: $full_script_path"

            fi

        else
            echo "not found: $full_script_path"
        fi

  }

  #add phpinfo() to a specified location
  function add_php_info(){

    if [[ ! -f "$1" ]]; then
        cat <<"EOL" > "$1"
        <?php
        phpinfo();
EOL
        chown www-data:www-data "$1"
    fi
  }

   #remove file from specified location
  function remove_file(){

    if [[ -f "$1" ]]; then
        rm "$1"
    fi

  }





