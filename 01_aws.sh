# shellcheck shell=bash
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html

[[ "${CLOUD_PROVIDER:-none}" == "aws" ]] || return 0

# AWS_METADATA_TOKEN is set by 00_cloud_detect.sh; fall back to a fresh fetch if missing.
METADATA_TOKEN="${AWS_METADATA_TOKEN:-$(curl -s --max-time 2 -X PUT \
    "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 60")}"

_aws_meta() {
    curl -s --max-time 2 \
        "http://169.254.169.254/latest/meta-data/$1" \
        -H "X-aws-ec2-metadata-token: ${METADATA_TOKEN}"
}

AWS_EC2_EXTERNAL_IP=$(_aws_meta 'public-ipv4')
AWS_EC2_EXTERNAL_IP=${AWS_EC2_EXTERNAL_IP:-'None'}
AWS_EC2_ID=$(_aws_meta 'instance-id')
AWS_EC2_TYPE=$(_aws_meta 'instance-type')
AWS_EC2_ZONE=$(_aws_meta 'placement/availability-zone')

echo -e "===== AWS INSTANCE METADATA ===================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${AWS_EC2_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance ID${RESET_COLORS}........: ${AWS_EC2_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance Type${RESET_COLORS}......: ${AWS_EC2_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${AWS_EC2_ZONE}"
