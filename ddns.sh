#!/bin/bash

# 載入 secret.sh，檢查是否存在
SECRET=$(dirname "$(realpath "$0")")/secret.sh
if [ ! -e "$SECRET" ]; then
    echo "Error: secret.sh does not exist."
    exit 1
fi
. "$SECRET"

# 取得目前的外部 IP
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)
if [ -z "$CURRENT_IP" ]; then
    echo "Error: Unable to fetch current IP."
    exit 1
fi

# 取得 DNS 記錄中的 IP
DNS_IP=$(dig +short "${URLS[0]}" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
if [ -z "$DNS_IP" ]; then
    echo "Error: Unable to fetch DNS IP for ${URLS[0]}."
    exit 1
fi

# 比較 IP，若不同則更新
if [ "$CURRENT_IP" != "$DNS_IP" ]; then
    echo "Updating IP: $DNS_IP -> $CURRENT_IP"
    for ((i = 0; i < ${#URLS[@]}; i++)); do
        RESPONSE=$(curl --silent --write-out "%{http_code}" --output /dev/null \
            --request PUT \
            --url "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/${RECORD_IDS[$i]}" \
            --header "Content-Type: application/json" \
            --header "X-Auth-Email: $EMAIL" \
            --header "Authorization: Bearer $KEY" \
            --data "{
                \"type\": \"A\",
                \"name\": \"${URLS[$i]}\",
                \"content\": \"$CURRENT_IP\"
            }")
        
        if [ "$RESPONSE" -eq 200 ]; then
            echo "Successfully updated ${URLS[$i]} to $CURRENT_IP."
        else
            echo "Error: Failed to update ${URLS[$i]}. HTTP status: $RESPONSE"
        fi
    done
else
    echo "No change needed: $CURRENT_IP"
fi