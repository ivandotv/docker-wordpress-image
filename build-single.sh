#!/bin/bash

set -e

# script to build the particular image
# $1 - must be a tag (I'm using directory names as tags)
# rest of the parameters will be passed to the "docker build" command
working_dir=''
temp_build_dir_name='build_dir'
username='ivandotv'
image_name='wordpress'

# script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# cd ${script_dir}/tags

function clean_up(){
    rm -rf "$working_dir/$temp_build_dir_name"
}

trap clean_up ERR EXIT

if [[ -z $1 ]]; then

    echo please "please provide directory"
    exit
fi

if [[ -z $2 ]]; then
    echo "please provide tag"
    exit
fi

working_dir=$1
image_tag=$2
latest=''

if [[ -n $3 ]];then
    latest=$3
    shift
fi

shift
shift

build_params="$@"

if [[ -d "${working_dir}" ]]; then

    temp_build_dir="${working_dir}/${temp_build_dir_name}"

    mkdir -p  $temp_build_dir

    rsync -aq  --exclude "$temp_build_dir_name" "${working_dir}/" "$temp_build_dir"
    rsync -aq --ignore-existing   build-assets/ "$temp_build_dir"

    echo 'building directory contents:'
    ls -la

    # do the build
    echo "starting build"

    full_image_name=${username}/${image_name}:${image_tag}

    if [[ "$latest" == 'latest' ]]; then

       latest_tag=" -t ${username}/${image_name}:latest"
       echo "also tagging this image with 'latest'"

    fi

    echo  ${build_params} '-t' ${full_image_name} ${latest_tag}

    echo "Starting build"

    if ! docker build ${build_params} -t ${full_image_name} ${latest_tag} ${temp_build_dir};then

        echo "docker build error"
        clean_up
        exit 1
    fi

else
    echo "directory for the tag: ${working_dir} doesn't exist"
fi
