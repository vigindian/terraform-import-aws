# Common Terraform Import Commands

## import vpc
```
terraform import aws_vpc.vpc-example vpc-123456
```

## import subnet
```
terraform import aws_subnet.subnet-example-2a subnet-abcde123
```

## import internet-gateway
```
terraform import aws_internet_gateway.igw-example igw-a1234bc
```

## import route-table
```
terraform import aws_route_table.rtb-example rtb-0123abc
```

## import vpc peering-connection
```
terraform import aws_vpc_peering_connection.peer-vpc1tovpc2 pcx-1234bc
```

## import route-table-association
```
terraform import aws_route_table_association.rta_sub2a-example subnet-abcde123/rtb-0123abc
```

## import ec2 key-pair
```
terraform import aws_key_pair.kp_example ec2-example-sshkey1
```

## import security-group
```
terraform import aws_security_group.vpc-sg-example-i-common sg-ab1234
#terraform state list|grep aws_security_group_rule | while read i;do terraform state rm $i;done
```

## import ec2
```
terraform import aws_instance.ec2_example1 i-0abc1234degh
```

## import ebs-volume and its attachment
```
terraform import aws_ebs_volume.ebs_example1 vol-0bacoa718346bg
terraform import aws_volume_attachment.ebsattach_example1-vol1 /dev/sdf:vol-0bacoa718346bg:i-0abc1234degh
```

## import elastic-ip and eip-association
```
terraform import aws_eip.example1 eipalloc-1c61816
terraform import aws_eip_association.eipassoc_example1 eipassoc-01365uabvfkja
```

## import route53-record
```
terraform import aws_route53_record.exampledomainAAAA R53ZONEID_example.com_AAAA
```

## import elastic-load-balancer
```
terraform import aws_elb.elb_exampleweb elb-example-web
```

## import application-load-balancer, target-group and alb-listener
```
terraform import aws_alb.alb-example-web arn:aws:elasticloadbalancing:ap-southeast-2:123456789:loadbalancer/app/alb-example-web/eb126481haj165
terraform import aws_alb_target_group.tg-web arn:aws:elasticloadbalancing:ap-southeast-2:123456789:targetgroup/tg-web/abc123456
terraform import aws_alb_listener.alb-example-web-https arn:aws:elasticloadbalancing:ap-southeast-2:123456789:listener/app/alb-example-web/eb126481haj165/abc123456
```

## import cloudfront-distribution
```
terraform import aws_cloudfront_distribution.cf_example E2HCFEMY1LVM
```

## import iam-group with its group-policy-attachment
```
terraform import aws_iam_group.accounts Accounts
terraform import aws_iam_group_policy.accounts_plact Accounts:AWSAccountActivityAccess-Accounts-1234
terraform import aws_iam_group_policy_attachment.accounts-s3 Accounts/arn:aws:iam::aws:policy/AmazonS3FullAccess
```

## import iam-policy
```
terraform import aws_iam_policy.webdev arn:aws:iam::123456789:policy/WebDev_Policy
```

## import iam-user, user-policy, and user-policy-attachment
```
terraform import aws_iam_user.user1 user1
terraform import aws_iam_user_policy.user1_ses user1:AmazonSesSendingAccess
terraform import aws_iam_user_policy_attachment.user1_s3 user1/arn:aws:iam::123456789:policy/AmazonS3Access-user1-s3
```

## import iam-role
```
terraform import aws_iam_role.app EC2Role_App1
#import iam-role-policy-attachment
terraform import aws_iam_role_policy_attachment.s3-app1-attach EC2Role_App1/arn:aws:iam::123456789:policy/S3App1
```

## import iam-instance-profile
```
terraform import aws_iam_instance_profile.app EC2Role_App
```

## import lambda-function
```
terraform import aws_lambda_function.cluster-lambda1 cluster-lambda1
```

## import redshift-cluster and its subnet-group
```
terraform import aws_redshift_cluster.cluster1 redshift-example1
terraform import aws_redshift_subnet_group.cluster1 cluster1-redshift-subnet
```

## import glue-crawler
```
terraform import aws_glue_crawler.cluster1 crawler-cluster1
```

## import kinesis-firehose-delivery-stream
```
terraform import aws_kinesis_firehose_delivery_stream.cluster1 arn:aws:firehose:ap-southeast-2:123456789:deliverystream/firehose-cluster1
```

## import kinesis stream
```
terraform import aws_kinesis_stream.stream1 stream1
```

## import step-function-state-machine
```
terraform import aws_sfn_state_machine.cluster1 arn:aws:states:ap-southeast-2:123456789:stateMachine:step1
```

## import cloudwatch-event-rule, event-target and corresponding sns-topic
```
terraform import aws_cloudwatch_event_rule.healthcheck1 Events-Notify1
##get target id from aws command and then import the events rule's target
##aws events list-targets-by-rule --rule "Events-Notify1"
terraform import aws_cloudwatch_event_target.healthcheck1 Events-Notify1/Id654321
terraform import aws_sns_topic.healthcheck1 email arn:aws:sns:ap-southeast-2:123456789:ScheduledEmail
terraform import aws_sns_topic_subscription.healthcheck1 arn:aws:sns:ap-southeast-2:123456789:ScheduledEmail:1548qgaja-1234-5678-abcd-5171gaba
```

## import acm-certificate
```
terraform import aws_acm_certificate.cert-example arn:aws:acm:ap-southeast-2:123456789:certificate/51716aga-abcd-1234-5678-gsjagauj
```

## import WAF logging config
```
terraform import aws_wafv2_web_acl_logging_configuration.waf-logs arn:aws:wafv2:ap-southeast-2:123456789:regional/webacl/waf-acl-alb/175jhaba-bbhy-1234-5678-gg5697ab
```

## import WAF ip-set, regex-pattern-set
```
terraform import aws_wafv2_ip_set.ipsetwhitelist 175jhaba-bbhy-1234-5678-gg5697ab/ipsetwhitelist/REGIONAL
terraform import aws_wafv2_regex_pattern_set.regexwhitelist 175jhaba-bbhy-1234-5678-gg5697ab/regexwhitelist/REGIONAL
```

## import s3 bucket and bucket-policy
```
terraform import aws_s3_bucket.examplerepo examplerepo.example.com
terraform import aws_s3_bucket_policy.examplerepo examplerepo.example.com
```
