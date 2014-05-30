#!/bin/bash

# started from ami-af7abed8: ubuntu/images/ebs/ubuntu-precise-12.04-amd64-server-20140428
# docker images serf/dnsmasq/ambari added
# after single node ambari installation its backed into:
# ami-a908cbde: 755047402263/docker-ambari-serf
# ami-d91ad8ae: v0.0
# ami-2121ec56: v0.1 docker ready linux with warmed ambari docker image
# ami-2f39f458 : v0.2 docker ready linux with warmed ambari docker image

# alternate candidate, from docker docs:
# http://docs.docker.io/installation/amazon/
# amzn-ami-pv-2014.03.1.x86_64-ebs (ami-2918e35e)

: ${DEBUG:=1}
debug() {
  [ -n "$DEBUG" ] && echo [DEBUG] "$@" 1>&2
}

debug-var() {
  VAR=$1
  debug $VAR=${!VAR}
}

run-cmd() {
  [ -n "$DEBUG" ] && echo [CMD] "$@" 1>&2
  "$@"
}

clear-params() {
unset ROLE INS_TYPE KEY_NAME OWNER EC2_NAME ROLE
}

: ${CLUSTER_SIZE:=4}
: ${INS_TYPE:=m3.medium}
: ${KEY_NAME:=sequence-eu}
: ${OWNER:=$USER}
: ${EC2_NAME:=amb-clust}
: ${ROLE:=Arn=arn:aws:iam::755047402263:instance-profile/readonly-role}
: ${AMI:=ami-2f39f458}
# this vpc/subnet was created with the cloudformation from cloudbreak-api
: ${SUBNET:=subnet-ec1bfc9b}

debug-var CLUSTER_SIZE
debug-var INS_TYPE
debug-var KEY_NAME
debug-var OWNER
debug-var EC2_NAME
debug-var ROLE
debug-var SUBNET

RUN_RESP=$(run-cmd \
  aws ec2 run-instances \
  --count $CLUSTER_SIZE \
  --image-id $AMI \
  --instance-type $INS_TYPE \
  --iam-instance-profile $ROLE \
  --key-name $KEY_NAME \
  --user-data file://./ec2-init.sh
)

# todo use vpc:
#--subnet-id $SUBNET \

RESERVATION=$(echo $RUN_RESP|jq .ReservationId -r)
debug-var RESERVATION

INSTANCES=$(echo $RUN_RESP|jq .Instances[].InstanceId -r)
debug-var INSTANCES

RESP=$(run-cmd aws ec2 create-tags --resources $INSTANCES --tags Key=owner,Value=$OWNER Key=Name,Value=$EC2_NAME --out text)
debug-var RESP

INTERFACES=$(aws ec2 describe-instances --instance-ids $INSTANCES --query Reservations[].Instances[].NetworkInterfaces[].NetworkInterfaceId --out text)
debug-var INTERFACES

debug disable src/dest check on all eni
for eni in $INTERFACES; do
  aws ec2 modify-network-interface-attribute --network-interface-id $eni --source-dest-check false --out text
done
