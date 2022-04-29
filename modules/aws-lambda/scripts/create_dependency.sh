#!/bin/sh

echo "Executing create_dependency.sh..."
ls
echo "${PWD}"
mkdir -p $path_build

dir_name=$path_build/deployment_package_$servicename/

echo "removing dir ${dir_name}"
rm -rf $dir_name
echo "creating dir ${dir_name}"
mkdir $dir_name

echo "${PWD}"
ls

test -f $path_files/ && echo "$path_files exists"
test -f $path_files/package && echo "$path_files/package exists"
test -f $path_files/$filename && echo "$path_files/$filename exists"


cp -ra $path_files/package $dir_name/package
cp -ra $path_files/$filename $dir_name/$filename

