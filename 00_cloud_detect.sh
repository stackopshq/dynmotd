# shellcheck shell=bash
# Shared cloud-provider detection. Runs once before any 01_*.sh module and
# exports CLOUD_PROVIDER (aws|gcp|azure|openstack|none). Each 01_*.sh checks
# this and returns early if it doesn't match.
#
# On non-cloud hosts this costs one connection attempt with a 1s timeout.
# On cloud hosts, the winning probe completes in well under a second.

CLOUD_PROVIDER='none'

# Quick reachability probe — most non-cloud hosts have no route to 169.254.169.254
# and fail immediately with "000".
_reach_status=$(curl -s --max-time 1 -o /dev/null -w '%{http_code}' \
    http://169.254.169.254/ 2>/dev/null)

if [[ "${_reach_status}" != "000" ]]; then
    # AWS IMDSv2 — token endpoint returns a non-empty body on EC2.
    # Cache the token so 01_aws.sh doesn't need to re-fetch it.
    AWS_METADATA_TOKEN=$(curl -s --max-time 2 -X PUT \
        "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 60" 2>/dev/null)

    if [[ -n "${AWS_METADATA_TOKEN}" ]]; then
        CLOUD_PROVIDER='aws'
        export AWS_METADATA_TOKEN
    elif [[ $(curl -s --max-time 2 -o /dev/null -w '%{http_code}' \
            -H "Metadata-Flavor: Google" \
            http://169.254.169.254/computeMetadata/v1/ 2>/dev/null) == '200' ]]; then
        # GCP — requires Metadata-Flavor header; 200 with it, 403 without.
        CLOUD_PROVIDER='gcp'
    elif [[ $(curl -s --max-time 2 -o /dev/null -w '%{http_code}' \
            -H "Metadata:true" --noproxy '*' \
            "http://169.254.169.254/metadata/instance?api-version=2020-09-01" 2>/dev/null) == '200' ]]; then
        # Azure IMDS — requires Metadata:true header.
        CLOUD_PROVIDER='azure'
    elif [[ $(curl -s --max-time 2 -o /dev/null -w '%{http_code}' \
            http://169.254.169.254/openstack/latest/meta_data.json 2>/dev/null) == '200' ]]; then
        # OpenStack — distinctive /openstack/ path.
        CLOUD_PROVIDER='openstack'
    fi
fi

unset _reach_status
export CLOUD_PROVIDER
