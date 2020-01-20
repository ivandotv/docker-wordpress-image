#!/bin/bash

tags_file="tags.txt"
latest=''

while read -r line; do

    # treat # at the beginning of the line as commented out tag
    if [[ ${line:0:1} != "#" ]]; then

        if [[ ${line:0:1} == "!" ]]; then

            line=${line#"!"}
            latest='latest'

        fi

       dir=$( echo "$line" | cut -d '=' -f 1 );
       tag=$( echo "$line" | cut -d '=' -f 2 );

       sleep 1

       if ! ./build-single.sh "$dir" "$tag" "$latest" "$@"; then
        echo "Error building image - stopping bulk build process"
        exit 1
       fi

       latest=''
    fi

done < "$tags_file"
