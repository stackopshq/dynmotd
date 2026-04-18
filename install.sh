#!/bin/bash
set -e

DYNMOTD_BIN_PATH='/usr/local/bin'
DYNMOTD_MODULES_PATH='/etc/dynmotd.d'
DYNMOTD_CONFIG='/etc/dynmotd.conf'
DYNMOTD_NOTICES_DIR='/var/lib/dynmotd/notices'
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo '+ starting install'

echo ' + installing dynmotd binary'
install -m 755 "${SRC_DIR}/dynmotd"         "${DYNMOTD_BIN_PATH}/dynmotd"
install -m 755 "${SRC_DIR}/dynmotd-notify"  "${DYNMOTD_BIN_PATH}/dynmotd-notify"
install -m 755 "${SRC_DIR}/dynmotd-exclude" "${DYNMOTD_BIN_PATH}/dynmotd-exclude"
ln -sf "${DYNMOTD_BIN_PATH}/dynmotd" "${DYNMOTD_BIN_PATH}/dm"

echo ' + setting up login hooks for detected shells'

DYNMOTD_MARKER_BEGIN='# >>> dynmotd >>>'
DYNMOTD_MARKER_END='# <<< dynmotd <<<'

# Idempotent: strips any previous dynmotd block between markers, then appends fresh.
write_shell_block() {
    local file="$1" body="$2" tmp lead=''
    mkdir -p "$(dirname "${file}")"
    if [[ -f "${file}" ]]; then
        tmp=$(mktemp "${file}.XXXXXX")
        awk -v b="${DYNMOTD_MARKER_BEGIN}" -v e="${DYNMOTD_MARKER_END}" '
            $0 == b { skip=1; next }
            $0 == e { skip=0; next }
            !skip   { print }
        ' "${file}" > "${tmp}"
        mv "${tmp}" "${file}"
    fi
    [[ -s "${file}" ]] && lead=$'\n'
    printf '%s%s\n%s\n%s\n' "${lead}" "${DYNMOTD_MARKER_BEGIN}" "${body}" "${DYNMOTD_MARKER_END}" >> "${file}"
    chmod 644 "${file}"
}

# bash — /etc/profile.d/*.sh is sourced by /etc/profile for login shells
cat > /etc/profile.d/dynmotd.sh <<EOF
[ -x ${DYNMOTD_BIN_PATH}/dynmotd ] && ${DYNMOTD_BIN_PATH}/dynmotd
EOF
chmod 644 /etc/profile.d/dynmotd.sh
echo '   bash: /etc/profile.d/dynmotd.sh'

# zsh — /etc/zsh/zprofile on Debian/Ubuntu/Arch, /etc/zprofile elsewhere
if command -v zsh >/dev/null 2>&1 || [[ -d /etc/zsh ]]; then
    if [[ -d /etc/zsh ]]; then
        ZSH_PROFILE='/etc/zsh/zprofile'
    else
        ZSH_PROFILE='/etc/zprofile'
    fi
    write_shell_block "${ZSH_PROFILE}" \
        "[ -x ${DYNMOTD_BIN_PATH}/dynmotd ] && ${DYNMOTD_BIN_PATH}/dynmotd"
    echo "   zsh:  ${ZSH_PROFILE}"
fi

# fish — /etc/fish/conf.d/*.fish is sourced on every fish startup
if command -v fish >/dev/null 2>&1 || [[ -d /etc/fish ]]; then
    mkdir -p /etc/fish/conf.d
    cat > /etc/fish/conf.d/dynmotd.fish <<EOF
if status is-login
    test -x ${DYNMOTD_BIN_PATH}/dynmotd; and ${DYNMOTD_BIN_PATH}/dynmotd
end
EOF
    chmod 644 /etc/fish/conf.d/dynmotd.fish
    echo '   fish: /etc/fish/conf.d/dynmotd.fish'
fi

echo ' + ensuring config file exists'
if [[ ! -f "${DYNMOTD_CONFIG}" ]]; then
    cat > "${DYNMOTD_CONFIG}" <<'EOF'
# dynmotd configuration file
# Add one username per line to exclude from MOTD display
# Example:
# root
# serviceaccount
EOF
    chmod 644 "${DYNMOTD_CONFIG}"
fi

echo ' + setting up notices directory'
mkdir -p "${DYNMOTD_NOTICES_DIR}"
chmod 755 "${DYNMOTD_NOTICES_DIR}"

echo ' + refreshing module directory'
mkdir -p "${DYNMOTD_MODULES_PATH}"
# Remove old project-owned modules so reinstalls stay clean.
# User-added modules (anything without a project prefix) are preserved.
rm -f "${DYNMOTD_MODULES_PATH}"/00_cloud_detect.sh \
      "${DYNMOTD_MODULES_PATH}"/00_notices.sh \
      "${DYNMOTD_MODULES_PATH}"/00_rhel.sh \
      "${DYNMOTD_MODULES_PATH}"/00_rocky.sh \
      "${DYNMOTD_MODULES_PATH}"/00_raspberry_pi.sh \
      "${DYNMOTD_MODULES_PATH}"/00_wsl.sh \
      "${DYNMOTD_MODULES_PATH}"/01_aws.sh \
      "${DYNMOTD_MODULES_PATH}"/01_azure.sh \
      "${DYNMOTD_MODULES_PATH}"/01_gcp.sh \
      "${DYNMOTD_MODULES_PATH}"/01_openstack.sh \
      "${DYNMOTD_MODULES_PATH}"/99_fortune.sh

echo ' + installing always-on modules'
# Shared cloud detection runs before any provider module and gates them at runtime.
install -m 644 "${SRC_DIR}/00_cloud_detect.sh" "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/00_notices.sh"      "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/00_wsl.sh"          "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/99_fortune.sh"      "${DYNMOTD_MODULES_PATH}/"

# All cloud provider modules are copied; each self-gates on CLOUD_PROVIDER at runtime.
install -m 644 "${SRC_DIR}/01_aws.sh"       "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/01_azure.sh"     "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/01_gcp.sh"       "${DYNMOTD_MODULES_PATH}/"
install -m 644 "${SRC_DIR}/01_openstack.sh" "${DYNMOTD_MODULES_PATH}/"

echo ' + detecting OS-specific modules'
if grep -q 'Raspbian' /etc/os-release 2>/dev/null || [[ -f /etc/rpi-issue ]]; then
    install -m 644 "${SRC_DIR}/00_raspberry_pi.sh" "${DYNMOTD_MODULES_PATH}/"
elif [[ -f /etc/rocky-release ]] && command -v tuned-adm >/dev/null 2>&1; then
    install -m 644 "${SRC_DIR}/00_rocky.sh" "${DYNMOTD_MODULES_PATH}/"
elif [[ -f /etc/redhat-release ]] && command -v tuned-adm >/dev/null 2>&1; then
    install -m 644 "${SRC_DIR}/00_rhel.sh" "${DYNMOTD_MODULES_PATH}/"
fi

echo '+ install complete!'
"${DYNMOTD_BIN_PATH}/dynmotd"
