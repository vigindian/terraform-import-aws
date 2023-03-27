#!/usr/bin/env python3

#json module
import json

key='TTL'

def check_key_exist(dict, key):
    try:
       value = dict[key]
       return True
    except KeyError:
        return False

#inputFile="out/r53_records.json"
inputFile="out/r53_records.json.sample"
#open input file with route 53 records
with open(inputFile, 'r') as f:
    r53_dict = json.load(f)

#identify number of records
length=len(r53_dict["ResourceRecordSets"])

#Header
print("Name;Type;TTL;Records;Alias")
#one at a time
for i in range(length):
    #empty array
    records=[]
    name=r53_dict["ResourceRecordSets"][i]["Name"]
    type=r53_dict["ResourceRecordSets"][i]["Type"]

    #alias record
    if not check_key_exist(r53_dict["ResourceRecordSets"][i], key):
        ttl="NA"

        #{'HostedZoneId': 'hostzedzoneid', 'DNSName': 'example.dns.com', 'EvaluateTargetHealth': False}
        alias=r53_dict["ResourceRecordSets"][i]["AliasTarget"]["DNSName"]

    #all other records
    else:
        ttl=r53_dict["ResourceRecordSets"][i]["TTL"]
        numrecords=len(r53_dict["ResourceRecordSets"][i]["ResourceRecords"])
        alias="NA"
        for r in range(numrecords):
          thisrecord=r53_dict["ResourceRecordSets"][i]["ResourceRecords"][r]["Value"]
          records.append(thisrecord)

    print(name + ";" + str(type) + ";" + str(ttl) + ";" + str(records) + ";" + str(alias))
