# https://cloud.google.com/appengine/docs/standard/java/accessing-instance-metadata
# https://cloud.google.com/compute/docs/reference/rest/v1/instances/list
GCP_EXTERNAL_IP=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip")
GCP_EXTERNAL_IP=${GCP_EXTERNAL_IP:-'None'}

GCP_PROJECT=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/project/project-id")
GCP_INSTANCE_MACHINE_TYPE=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/machine-type" | xargs basename)
GCP_INSTANCE_IMAGE=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/image" | xargs basename)
GCP_INSTANCE_PREEMPTIBLE=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/scheduling/preemptible")
GCP_INSTANCE_VPC=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/network" | xargs basename)
GCP_INSTANCE_ZONE=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "metadata.google.internal/computeMetadata/v1/instance/zone" | xargs basename)

input_scopes=$(curl -s --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes")

# https://cloud.google.com/compute/docs/access/service-accounts#default_scopes
DEFAULT_SCOPE=(
  "devstorage.read_only"
  "logging.write"
  "monitoring.write"
  "service.management.readonly"
  "servicecontrol"
  "trace.append"
)

# Initialize the ADDITIONAL_SCOPE list
ADDITIONAL_SCOPE=()

# Read the input line by line
while IFS= read -r line; do
  # Remove leading/trailing whitespace
  line=$(echo "$line" | xargs)

  # Skip empty lines
  if [[ -z "$line" ]]; then
    continue
  fi

  # Get the basename of the URL
  basename=$(basename "$line")

  # Check if the basename is in DEFAULT_SCOPE
  is_default=false
  for default_item in "${DEFAULT_SCOPE[@]}"; do
    if [[ "$basename" == "$default_item" ]]; then
      is_default=true
      break
    fi
  done

  # If not a member of DEFAULT_SCOPE, add to ADDITIONAL_SCOPE
  if ! $is_default; then
    ADDITIONAL_SCOPE+=("$basename")
  fi

done <<< "$input_scopes" # Use here-string to feed the input

# Join the ADDITIONAL_SCOPE array elements with commas
GCP_ADDITIONAL_SCOPES=$(IFS=,; echo "${ADDITIONAL_SCOPE[*]}")


echo -e "===== GCP INSTANCE METADATA ===================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- External IP${RESET_COLORS}........: ${GCP_EXTERNAL_IP}
 ${COLOR_COLUMN}${COLOR_VALUE}- Project ID${RESET_COLORS}.........: ${GCP_PROJECT}
 ${COLOR_COLUMN}${COLOR_VALUE}- Machine Type${RESET_COLORS}.......: ${GCP_INSTANCE_MACHINE_TYPE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Image${RESET_COLORS}..............: ${GCP_INSTANCE_IMAGE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Preemptible${RESET_COLORS}........: ${GCP_INSTANCE_PREEMPTIBLE}
 ${COLOR_COLUMN}${COLOR_VALUE}- VPC${RESET_COLORS}................: ${GCP_INSTANCE_VPC}
 ${COLOR_COLUMN}${COLOR_VALUE}- Zone${RESET_COLORS}...............: ${GCP_INSTANCE_ZONE}
 ${COLOR_COLUMN}${COLOR_VALUE}- Additional Scopes${RESET_COLORS}..: [${GCP_ADDITIONAL_SCOPES}]"
