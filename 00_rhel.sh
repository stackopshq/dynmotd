# shellcheck shell=bash
# RHEL/Oracle Linux specific info
TUNED_PROFILE=$(tuned-adm active 2>/dev/null | awk -F': ' '{ print $2 }')
TUNED_PROFILE=${TUNED_PROFILE:-'N/A'}

echo -e "===== RHEL/OL INFO ============================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- Tuned profile${RESET_COLORS}......: ${TUNED_PROFILE}"
