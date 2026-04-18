# shellcheck shell=bash
command -v fortune >/dev/null 2>&1 || return 0
FORTUNE=$(fortune 2>/dev/null)

if [ -n "${FORTUNE}" ]
then
  echo -e "===== FORTUNE =================================================================
${FORTUNE}"
fi
