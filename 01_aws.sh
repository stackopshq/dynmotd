# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html
METADATA_TOKEN=$(curl -s --max-time 2 --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 30")

AWS_EC2_EXTERNAL_IP=$(curl --fail -s --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 --header "X-aws-ec2-metadata-token: ${METADATA_TOKEN}")
AWS_EC2_EXTERNAL_IP=${AWS_EC2_EXTERNAL_IP:-'None'}

AWS_EC2_ID=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: ${METADATA_TOKEN}")
AWS_EC2_TYPE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/instance-type --header "X-aws-ec2-metadata-token: ${METADATA_TOKEN}")
AWS_EC2_ZONE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/availability-zone --header "X-aws-ec2-metadata-token: ${METADATA_TOKEN}")

echo -e "===== AWS INSTANCE METADATA ===================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${AWS_EC2_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance ID${RESET_COLORS}........: ${AWS_EC2_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance Type${RESET_COLORS}......: ${AWS_EC2_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${AWS_EC2_ZONE}"
