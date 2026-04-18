# shellcheck shell=bash
# https://docs.openstack.org/nova/latest/user/metadata.html
# OpenStack exposes both the AWS-compatible endpoint and /openstack/.

[[ "${CLOUD_PROVIDER:-none}" == "openstack" ]] || return 0

_os_meta() {
    curl -s --max-time 2 "http://169.254.169.254/latest/meta-data/$1" 2>/dev/null
}

OS_EXTERNAL_IP=$(curl --fail -s --max-time 2 \
    http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
OS_EXTERNAL_IP=${OS_EXTERNAL_IP:-'None'}

OS_INSTANCE_ID=$(_os_meta 'instance-id')
OS_INSTANCE_TYPE=$(_os_meta 'instance-type')
OS_HOSTNAME=$(_os_meta 'hostname')
OS_ZONE=$(_os_meta 'placement/availability-zone')
OS_PROJECT_ID=$(_os_meta 'project-id')
if [[ -z "${OS_PROJECT_ID}" ]]; then
    OS_PROJECT_ID=$(curl -s --max-time 2 \
        http://169.254.169.254/openstack/latest/meta_data.json 2>/dev/null \
        | grep -o '"project_id": *"[^"]*"' | awk -F'"' '{print $4}')
fi

echo -e "===== OPENSTACK INSTANCE METADATA =============================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${OS_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance ID${RESET_COLORS}........: ${OS_INSTANCE_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Instance Type${RESET_COLORS}......: ${OS_INSTANCE_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Hostname${RESET_COLORS}...........: ${OS_HOSTNAME}
 ${COLOR_COLUMN}${COLOR_VALUE}- Project ID${RESET_COLORS}.........: ${OS_PROJECT_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${OS_ZONE}"
