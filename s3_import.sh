#!/bin/bash

# s3 import

#user input: directory to import the terraform state
ENV="$1"

#Other Variables
sample="./sample/s3.tf.sample"     #Sample file to be used for import
tfstate="terraform.tfstate"
import=1        #switch to enable/disable terraform import - 1 is enable
current=$(pwd)
CMD="aws s3 ls"

echo 
if [ -z $ENV ] ;then

        echo "Usage: $0 directory_to_import"
        echo
        echo "Prepare input files for Validation (NO import): $0 local"
        echo "Prepare and import: $0 staging|test|qa|production"

        echo
        exit 1
fi

#this script expects target directories with specific name and path. Change this accordingly
case "$ENV" in
    tst|test)
        ename="test"
        location="../test"
        ;;
    qa)
        ename="qa"
        location="../qa"
        ;;
    stg|staging)
        ename="stg"
        location="../staging"
        ;;
    prod|production)
        ename="prd"
        location="../production"
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

#only imports s3 buckets with given environment-name in its bucket-name. Please change this according to your environment
$CMD | grep "\-${ename}" | awk '{print $NF}'|while read i
do
        BNAME=$i
	TNAME=$(echo ${BNAME}|tr '\.' '-')
        echo $BNAME
        rfile="${location}/s3_${BNAME}.tf"

	#Check if resource is already managed by Terraform
	cat ${location}/${tfstate} | grep -w "arn:aws:s3:::${BNAME}" > /dev/null
	if [ $? -eq 0 ];then
		echo "${BNAME} is already managed by Terraform"
		continue #go to next item
	fi

        cat "${sample}" | sed "s/NAME/${TNAME}/g" > ${rfile}

        #Check if import is enabled
        if [ $import -eq 1 ] ;then
                echo "Let us import the s3 bucket ${BNAME} into Terraform in ${location}"
                cd ${location}
                terraform import aws_s3_bucket.${TNAME} ${BNAME}

                #if import is successful, update the local file: ensure local file does not perform any changes in next terraform run
                if [ $? -eq 0 ];then
                        #get data from terraform and remove special chars
                        terraform state show aws_s3_bucket.${TNAME}|sed 's///g'| sed 's/\[0m//g'|sed 's/\[1m//g' |egrep -vw "id|bucket_domain_name|bucket_regional_domain_name" > ${rfile}
                fi

                cd ${current}
        fi

done
