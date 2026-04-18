#!/bin/bash
set -e

DYNMOTD_BIN_PATH='/usr/local/bin'
DYNMOTD_MODULES_PATH='/etc/dynmotd.d'

echo '+ starting uninstall'

# Strip the dynmotd block from any zprofile it was appended to.
strip_shell_block() {
    local file="$1" tmp
    [[ -f "${file}" ]] || return 0
    tmp=$(mktemp "${file}.XXXXXX")
    awk '
        $0 == "# >>> dynmotd >>>" { skip=1; next }
        $0 == "# <<< dynmotd <<<" { skip=0; next }
        !skip { print }
    ' "${file}" > "${tmp}"
    # Remove file entirely if stripping left it empty or whitespace-only.
    if [[ -s "${tmp}" ]] && grep -q '[^[:space:]]' "${tmp}"; then
        mv "${tmp}" "${file}"
    else
        rm -f "${tmp}" "${file}"
    fi
}

rm -f /etc/profile.d/dynmotd.sh
rm -f /etc/fish/conf.d/dynmotd.fish
strip_shell_block /etc/zsh/zprofile
strip_shell_block /etc/zprofile

rm -rf "${DYNMOTD_MODULES_PATH}"
rm -rf /var/lib/dynmotd
rm -f "${DYNMOTD_BIN_PATH}/dm"
rm -f "${DYNMOTD_BIN_PATH}/dynmotd"
rm -f "${DYNMOTD_BIN_PATH}/dynmotd-notify"
rm -f "${DYNMOTD_BIN_PATH}/dynmotd-exclude"
rm -f /etc/dynmotd.conf

echo '+ uninstall complete!'
