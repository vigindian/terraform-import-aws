#!/usr/bin/env bash
################################################################################################################
#
# Get AWS SG records and convert them into terraform format, so it can be imported into terraform state
#
# VN v1.0 201909
#
################################################################################################################

#user input: directory to import the terraform state
ENV="$1"

#Other Variables
tfstate="terraform.tfstate"
import=1        #switch to enable/disable terraform import - 1 is enable
current=$(pwd)

#aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output text

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

#get sg records using aws cli: expects environment-name in its name. Change this accordingly
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output text | grep "${ename}"| while read i
do
	sgid=$(echo $i | awk '{print $1}')
	sgname=$(echo $i | awk '{print $2}')
	sgdesc=$(echo $i | awk '{$1=$2=""; print $0}'|sed -e 's/^[[:space:]]*//')	#everything after first 2 columns without leading whitespace

	#Check if resource is already managed by Terraform
	if [ -f ${location}/${tfstate} ] ; then
		cat ${location}/${tfstate} | grep -w ${sgname} | grep -w name > /dev/null
		if [ $? -eq 0 ];then
			echo "${sgname} is already managed by Terraform"
			continue	
		fi
	fi

	rfile="${location}/sg_${sgname}.tf"

	#prepare terraform input file, for import
	echo -e "resource \"aws_security_group\" \"${sgname}\" {\n\tname = \"${sgname}\"\n\tvpc_id = \"\${aws_vpc.vpc-prd.id}\"\n\tdescription = \"${sgdesc}\"\n\ttags = {\n\t\tEnvironment = \"\${var.environment_tag}\"\n\t\tName = \"\${var.sg_common}\"\n\t}\n}" > ${rfile}

	#Check if import is enabled
	if [ $import -eq 1 ] ;then
		echo "Let us import the record ${sgname} into Terraform in ${location}"
		cd ${location}
		terraform import aws_security_group.${sgname} ${sgid}

		#cleanup sg rules, to prevent terraform from re-creating sg rules during terraform import/apply
		terraform state list|grep aws_security_group_rule | while read sgrule
		do
			terraform state rm ${sgrule}
		done

		#if import is successful, update the local file: ensure local file does not perform any changes in next terraform run
		if [ $? -eq 0 ];then
			#get data from terraform and remove special chars
			terraform state show aws_security_group.${sgname}|sed 's///g'| sed 's/\[0m//g'|sed 's/\[1m//g' |egrep -vw "id|owner_id|arn|timeouts" > ${rfile}
		fi

		cd ${current}
	fi

	echo ======================================================
done
