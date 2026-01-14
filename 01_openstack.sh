# https://docs.openstack.org/nova/latest/user/metadata.html
# OpenStack uses the same metadata endpoint as AWS (169.254.169.254)

OS_EXTERNAL_IP=$(curl --fail -s --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
OS_EXTERNAL_IP=${OS_EXTERNAL_IP:-'None'}

OS_INSTANCE_ID=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
OS_INSTANCE_TYPE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null)
OS_HOSTNAME=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/hostname 2>/dev/null)
OS_ZONE=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null)
OS_PROJECT_ID=$(curl -s --max-time 2 http://169.254.169.254/latest/meta-data/project-id 2>/dev/null)
OS_PROJECT_ID=${OS_PROJECT_ID:-$(curl -s --max-time 2 http://169.254.169.254/openstack/latest/meta_data.json 2>/dev/null | grep -o '"project_id": *"[^"]*"' | awk -F'"' '{print $4}')}

echo -e "===== OPENSTACK INSTANCE METADATA =============================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${OS_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance ID${RESET_COLORS}........: ${OS_INSTANCE_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance Type${RESET_COLORS}......: ${OS_INSTANCE_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Hostname${RESET_COLORS}...........: ${OS_HOSTNAME}
 ${COLOR_COLUMN}${COLOR_VALUE}- Project ID${RESET_COLORS}.........: ${OS_PROJECT_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${OS_ZONE}"
