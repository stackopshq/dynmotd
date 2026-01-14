FORTUNE=$(fortune 2> /dev/null)

if [ -n "${FORTUNE}" ]
then
  echo -e "===== FORTUNE =================================================================
${FORTUNE}"
fi
