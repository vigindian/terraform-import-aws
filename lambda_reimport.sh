#!/bin/bash

# Use this to re-import lambda functions into terraform state, if it was changed outside terraform

#user input: directory to import the terraform state
ENV="$1"

#Other Variables
tfstate="terraform.tfstate"
import=1        #switch to enable/disable terraform import - 1 is enable
current=$(pwd)
CMD="ls"

echo 
if [ -z $ENV ] ;then

        echo "Usage: $0 directory_to_import"
        echo
        echo "Prepare input files for Validation (NO import): $0 local"
        echo "Prepare and import: $0 global"

        echo
        exit 1
fi

#this script expects target directories with specific name and path. Change this accordingly
case "$ENV" in
    global)
        ename="global"
        location="../global"
        ;;
    local)
	#use local dir - can be used for validation before import
	ename="local"
        location="./local"
	import=0
        ;;
    *)
	echo "Invalid input"
	exit 3
	;;
esac

#check if dir exists within the repo. 
if [ ! -d $location ] ;then
	echo "The directory ${location} does NOT exist. Please provide a valid directory name within the repo"
	echo
	exit 2
fi

echo "Let us refresh terraform state in ${location} i.e. get remote state into local..."
cd ${location}
terraform refresh
if [ $? -ne 0 ];then
	echo "ERROR: terraform refresh failed. Aborting."
	exit 3
fi

#expects terraform file-names start with lambda - update this accordingly
$CMD ${location}/lambda*.tf |awk '{print $NF}'|while read i
do 
	BNAME=$i
	TNAME=$(cat ${BNAME}|grep -w resource|awk '{print $3}'|sed 's/"//g')
	echo $BNAME
	rfile="${BNAME}"

	#Check if resource is already managed by Terraform
        cat ${location}/${tfstate} | grep -w "${TNAME}" > /dev/null
        if [ $? -ne 0 ];then
                echo "WARN: ${TNAME} is NOT managed by Terraform! So cannot re-import"
                continue #go to next item
        fi

	#Check if import is enabled
	if [ $import -eq 1 ] ;then
		echo "Let us re-import the lambda func ${TNAME} into Terraform in ${location}"
		#cd ${location}
		#get data from terraform and remove special chars
		terraform state show aws_lambda_function.${TNAME}|sed 's///g'| sed 's/\[0m//g'|sed 's/\[1m//g' |egrep -vw "^    arn|id|vpc_id|invoke_arn|last_modified|layers|memory_size|publish|qualified_arn|reserved_concurrent_executions|source_code_hash|source_code_size|version" > ${rfile}

		#cd ${current}
	fi
done
