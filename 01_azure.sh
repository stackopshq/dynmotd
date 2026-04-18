# shellcheck shell=bash
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service?tabs=linux
# The "&format=text" suffix is required or the endpoint returns JSON.

[[ "${CLOUD_PROVIDER:-none}" == "azure" ]] || return 0

API_VERSION='2020-09-01'

_azure_meta() {
    curl -s --max-time 2 -H 'Metadata:true' --noproxy '*' \
        "http://169.254.169.254/metadata/instance/$1?api-version=${API_VERSION}&format=text"
}

AZURE_VM_EXTERNAL_IP=$(curl -s --max-time 2 -H 'Metadata:true' --noproxy '*' \
    "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipaddress/0/publicip?api-version=2017-03-01&format=text")
AZURE_VM_EXTERNAL_IP=${AZURE_VM_EXTERNAL_IP:-'None'}
AZURE_RG=$(_azure_meta 'compute/resourceGroupName')
AZURE_VM_ID=$(_azure_meta 'compute/vmId')
AZURE_VM_SIZE=$(_azure_meta 'compute/vmSize')
AZURE_VM_LOCATION=$(_azure_meta 'compute/location')

echo -e "===== AZURE INSTANCE METADATA =================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${AZURE_VM_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Resource Group${RESET_COLORS}.....: ${AZURE_RG}
 ${COLOR_COLUMN}${COLOR_VALUE}- VM ID${RESET_COLORS}..............: ${AZURE_VM_ID}
 ${COLOR_COLUMN}${COLOR_VALUE}- VM Size${RESET_COLORS}............: ${AZURE_VM_SIZE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Location${RESET_COLORS}...........: ${AZURE_VM_LOCATION}"
