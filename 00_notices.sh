# shellcheck shell=bash
# Display sysadmin notices. Notices are plain-text files in
# /var/lib/dynmotd/notices/ with optional first-line expiration
# (# expires: YYYY-MM-DD). Managed via `dynmotd-notify`.

_show_notices() {
    local dir='/var/lib/dynmotd/notices'
    [[ -d "${dir}" ]] || return 0

    local today
    today=$(date +%Y-%m-%d)

    local notices=() f text expires
    for f in "${dir}"/*.notice; do
        [[ -f "${f}" ]] || continue
        expires=$(awk -F': *' '/^# *expires:/ {print $2; exit}' "${f}")
        if [[ -n "${expires}" ]] && [[ "${expires}" < "${today}" ]]; then
            continue
        fi
        text=$(grep -v '^#' "${f}" | sed '/^$/d')
        [[ -n "${text}" ]] && notices+=("${text}")
    done

    if [[ ${#notices[@]} -gt 0 ]]; then
        echo '===== NOTICES ================================================================='
        for text in "${notices[@]}"; do
            while IFS= read -r line; do
                printf ' %b*%b %s\n' "${COLOR_COLUMN}${COLOR_VALUE}" "${RESET_COLORS}" "${line}"
            done <<< "${text}"
        done
    fi
}
_show_notices
unset -f _show_notices
