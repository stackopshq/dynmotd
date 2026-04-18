# shellcheck shell=bash
# https://cloud.google.com/compute/docs/metadata/overview

[[ "${CLOUD_PROVIDER:-none}" == "gcp" ]] || return 0

_gcp_meta() {
    curl -s --max-time 2 -H "Metadata-Flavor: Google" \
        "http://metadata.google.internal/computeMetadata/v1/$1"
}

GCP_EXTERNAL_IP=$(_gcp_meta 'instance/network-interfaces/0/access-configs/0/external-ip')
GCP_EXTERNAL_IP=${GCP_EXTERNAL_IP:-'None'}
GCP_PROJECT=$(_gcp_meta 'project/project-id')
GCP_INSTANCE_MACHINE_TYPE=$(_gcp_meta 'instance/machine-type' | xargs basename)
GCP_INSTANCE_IMAGE=$(_gcp_meta 'instance/image' | xargs basename)
GCP_INSTANCE_PREEMPTIBLE=$(_gcp_meta 'instance/scheduling/preemptible')
GCP_INSTANCE_VPC=$(_gcp_meta 'instance/network-interfaces/0/network' | xargs basename)
GCP_INSTANCE_ZONE=$(_gcp_meta 'instance/zone' | xargs basename)

# https://cloud.google.com/compute/docs/access/service-accounts#default_scopes
DEFAULT_SCOPES=(
    'devstorage.read_only'
    'logging.write'
    'monitoring.write'
    'service.management.readonly'
    'servicecontrol'
    'trace.append'
)

ADDITIONAL_SCOPES=()
while IFS= read -r line; do
    line=$(echo "${line}" | xargs)
    [[ -z "${line}" ]] && continue
    scope=$(basename "${line}")
    is_default=0
    for default in "${DEFAULT_SCOPES[@]}"; do
        if [[ "${scope}" == "${default}" ]]; then
            is_default=1
            break
        fi
    done
    [[ "${is_default}" -eq 0 ]] && ADDITIONAL_SCOPES+=("${scope}")
done <<< "$(_gcp_meta 'instance/service-accounts/default/scopes')"

GCP_ADDITIONAL_SCOPES=$(IFS=,; echo "${ADDITIONAL_SCOPES[*]}")

echo -e "===== GCP INSTANCE METADATA ===================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${GCP_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Project ID${RESET_COLORS}.........: ${GCP_PROJECT}
 ${COLOR_COLUMN}${COLOR_VALUE}- Machine Type${RESET_COLORS}.......: ${GCP_INSTANCE_MACHINE_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Image${RESET_COLORS}..............: ${GCP_INSTANCE_IMAGE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Preemptible${RESET_COLORS}........: ${GCP_INSTANCE_PREEMPTIBLE}
 ${COLOR_COLUMN}${COLOR_VALUE}- VPC${RESET_COLORS}................: ${GCP_INSTANCE_VPC}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${GCP_INSTANCE_ZONE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Additional Scopes${RESET_COLORS}..: [${GCP_ADDITIONAL_SCOPES}]"
