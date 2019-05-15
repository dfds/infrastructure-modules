if [ -z "$4" ]; then
    echo "Need 4 arguments"
    exit 1
fi


if [[ ${2} == "==" ]]; then
    cat ${1} | jq  --arg domain_name ${3} --arg index ${4} 'map(select(.domain_name == $domain_name))[$index|tonumber]'
else
    cat ${1} | jq  --arg domain_name ${3} --arg index ${4} 'map(select(.domain_name != $domain_name))[$index|tonumber]'
fi