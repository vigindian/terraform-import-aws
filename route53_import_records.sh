#!/usr/bin/env bash
################################################################################################################
#
# Get AWS R53 records and convert them into terraform format, so it can be imported into terraform state
#
# VN v1.0 201909
#
################################################################################################################

#user input: directory to import the terraform state
ENV="$1"

#Other Variables
zone_id="YOURR53HOSTEDZONEID"	#R53 hosted zone id for your domain
sample="./sample/route53.tf.sample"	#Sample file to be used for import
tfstate="terraform.tfstate"
import=1        #switch to enable/disable terraform import - 1 is enable
current=$(pwd)

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

#check if dir exists within the repo. As of Sep' 2019, only production and staging (only stg-voip in aws) exists
if [ ! -d $location ] ;then
	echo "The directory ${location} does NOT exist. Please provide a valid directory name within the repo"
	echo
	exit 2
fi

#get r53 records using aws cli
aws route53 list-resource-record-sets --hosted-zone-id ${zone_id} --output text | grep -w RESOURCERECORDSETS | while read i
do
	record=$(echo $i | awk '{print $2}')
	type=$(echo $i | awk '{print $4}')

	#alias entries has type in 3rd column
	if [ -z $type ] ;then
		type=$(echo $i | awk '{print $3}')
	fi

	short=$(echo $record | awk -F"." '{print $1}')
	RNAME="${short}${type}"
	rfile="${location}/r53_${RNAME}-record-${ename}.tf"
	#ZONEID_RECORDNAME_TYPE_SETIDENTIFIER
	#echo "${zone_id}_${record}_${type}"

	#Check if resource is already managed by Terraform
	cat ${location}/${tfstate} | grep -w ${RNAME} | grep -w name > /dev/null
	if [ $? -eq 0 ];then
		echo "${RNAME} is already managed by Terraform"
		continue
	fi

	SAMPLE=$sample
	#The hosted zone uses alias target
	if [ "$RNAME" == "exampleA" ] ;then
		#echo "$RNAME is same as exampleA"
		SAMPLE="./sample/route53_alias.tf.sample"
	fi

	#echo "sample file is $sample"

	#prepare terraform input file, for import
	cat "${SAMPLE}" | sed "s/RNAME/${RNAME}/g" | sed "s/FULLNAME/${record}/g" | sed "s/TYPE/${type}/g" > ${rfile}

	#Check if import is enabled
	if [ $import -eq 1 ] ;then
		echo "Let us import the record ${RNAME} into Terraform in ${location}"
		cd ${location}
		terraform import aws_route53_record.${RNAME} ${zone_id}_${record}_${type}

		#if import is successful, update the local file: ensure local file does not perform any changes in next terraform run
		if [ $? -eq 0 ];then
			#get data from terraform and remove special chars
			terraform state show aws_route53_record.${RNAME}|sed 's///g'| sed 's/\[0m//g'|sed 's/\[1m//g' |egrep -vw "id|fqdn" > ${rfile}
		fi

		cd ${current}
	fi

	echo ======================================================
done
