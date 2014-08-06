#!/bin/bash

#redhat
: ${OWNER:=309956199498}
#: ${FILTER:=RHEL-6.5}
: ${FILTER:=RHEL-6.5_GA-x86_64-7}


get-ami-by-region() {
  case $1 in
    eu-west-1) AMI=ami-af6faad8 ;;
    sa-east-1) AMI=ami-5fc76a42 ;;
    us-east-1) AMI=ami-5b697332 ;;
    us-west-2) AMI=ami-e08efbd0 ;;
    us-west-1) AMI=ami-5cdce419;;
    ap-southeast-1) AMI=ami-dcbeed8e ;;
    ap-southeast-2) AMI=ami-452eb67f ;;
    *) echo [ERROR] unknown region:\"$1\"
  esac

  echo $AMI
}

list-image-in-region() {
  REG=$1
  : ${REG:? region required}

  aws ec2 describe-images \
    --region $REG \
    --owners $OWNER \
    --filter Name=virtualization-type,Values=paravirtual \
    --query "Images[].{id:ImageId, name:Name, type:VirtualizationType, loc:ImageLocation, desc:Description}" \
    --out table \
    | grep $FILTER
}

list-images-all-regions() {
  #REGIONS=$(aws ec2 describe-regions --query Regions[].RegionName --out text)
  # ap-northeast-1 removed from list

  REGIONS="eu-west-1 sa-east-1 us-east-1 us-west-2 us-west-1 ap-southeast-1 ap-southeast-2"
  for reg in $REGIONS; do
    echo -e "\n[$reg]"
    list-image-in-region $reg
  done
}

list-images-all-regions
