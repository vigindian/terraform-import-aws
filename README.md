# Terraform Import Utilities for AWS

You can use these utilities to import existing AWS resources into terraform:
- [route53_import_records](./route53_import_records.sh): import r53 records
- [s3_import](./s3_import.sh): import s3 buckets
- [sg_import](./sg_import.sh): import security-groups
- [lambda_reimport](./lambda_reimport.sh): re-import lambda functions

## Script Pre-requisites
- import script creates terraform files and hence expects target directories with specific directory-name in specific-path. Please change this according to your environment.
- some import scripts only imports resources with given environment-name in its resource-name. Please change this according to your environment.
- the script runs aws cli commands with default profile. Please change this according to your environment.

## Other Utilities
- [route53-hostedzone-export](./route53-hostedzone-export): command to export r53 records in json format.
- [r53jsontotext](./r53jsontotext.py): convert r53 records json file into semi-colon delimited format, for easy visualisation in excel. You can run command in route53-hostedzone-export first, and then run this utility.

## Common Terraform Import Commands
- [common-import-commands](./common-import-commands.md): contains a set of common terraform import commands
