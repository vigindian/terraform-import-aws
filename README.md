# Terraform Import Utilities for AWS

You can use these utilities to import existing AWS resources into terraform:
- route53_import_records.sh: import r53 records
- s3_import.sh: import s3 buckets
- sg_import.sh: import security-groups
- lambda_reimport.sh: re-import lambda functions

## Script Pre-requisites
- import script creates terraform files and hence expects target directories with specific directory-name in specific-path. Please change this accordingly in the corresponding import-script
- some import scripts only imports resources with given environment-name in its resource-name. Please change this according to your environment

## Other Utilities
- r53jsontotext.py: convert r53 records json file into semi-colon delimited format, for easy visualisation in excel

## Common Terraform Import Commands
- common-import-commands: contains a set of common terraform import commands
