#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# get telegram bot token from @BotFather
tg_bot_token=$(echo $TG_BOT_TOKEN)
# sets the base API url
tg_api_url=$(echo "https://api.telegram.org")
# set the base request url
tg_base_request_url="${tg_api_url}/bot${tg_bot_token}"
# calculate offset needed for getUpdates
[[ -z "${TG_LAST_UPDATE_ID}" ]] && tg_last_update_id="0" || tg_last_update_id="${TG_LAST_UPDATE_ID}"

function moin_function() {
    result=$(curl -s "${tg_base_request_url}/getMe")
    bot_user_name=$(echo $result | jq -r ".result.username")
    echo -n "${bot_user_name} Started"
    while true; do 
        webm_conversion_process
        # sleep one second between updates
        sleep 1
    done
}

function call_api() {
    # experimental function
    ignore_proce=$(curl -X POST "${MP4_TO_WEBM_API_URL}" \
        -H "User-Agent: TelegramBot (like TwitterBot)" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"bot_token\": \"${1}\", \"chat_id\": \"${2}\", \
           \"message_id\": \"${3}\", \"file_id\": \"${4}\", \
           \"emojie\": \"${5}\"}"
    )
    echo $ignore_proce
}

function webm_conversion_process() {
    local i update message_id chat_id text

	local updates=$(curl -s "${tg_base_request_url}/getUpdates?offset=$tg_last_update_id")
	local count_update=$(echo $updates | jq -r ".result | length")

    [[ $count_update -eq 0 ]] && echo -n "."

    for ((i=0; i < $count_update; i++)); do
        update=$(echo $updates | jq -r ".result[$i]")   
    	tg_last_update_id=$(echo $update | jq -r ".update_id")
    	message_id=$(echo $update | jq -r ".message.message_id")
    	chat_id=$(echo $update | jq -r ".message.chat.id")
        text=$(echo $update | jq -r ".message.text")

        local update_with_animation=$(echo $update | jq -r ".message | select(.animation !=null)")
        local update_with_video=$(echo $update | jq -r ".message | select(.video !=null)")
        local message_caption=$(echo $update | jq -r ".message | select(.caption !=null)")

        if [ "${text}" != "null" ]; then
            msg="/start: https://github.com/SpEcHiDe/Mp4ToWebmBot"
            result=$(curl -s "${tg_base_request_url}/sendMessage" \
                        -d chat_id="${chat_id}" \
                        -d text="${msg}" \
                        -d parse_mode="HTML" \
                        -d reply_to_message_id="${message_id}"
                )

        elif [ ! -n "$update_with_animation" ]; then
            msg='please wait. contact @DonateMeRoBot to support this bot'
            result=$(curl -s "${tg_base_request_url}/sendMessage" \
                        -d chat_id="${chat_id}" \
                        -d text="${msg}" \
                        -d parse_mode="HTML" \
                        -d reply_to_message_id="${message_id}"
                )
            file_id=$(echo $update_with_animation | jq -r ".file_id")
            [[ -n "${message_caption}" ]] && emojie="🤔" || emojie="${message_caption}"
            tluser=$(call_api "$tg_bot_token" "$chat_id" "$message_id" "${file_id}" "${emojie}" )
            echo $tluser

        elif [ ! -n "$update_with_video" ]; then
            msg='please wait. contact @DonateMeRoBot to support this bot'
            result=$(curl -s "${tg_base_request_url}/sendMessage" \
                        -d chat_id="${chat_id}" \
                        -d text="${msg}" \
                        -d parse_mode="HTML" \
                        -d reply_to_message_id="${message_id}"
                )
            file_id=$(echo $update_with_animation | jq -r ".file_id")
            [[ -n "${message_caption}" ]] && emojie="🤔" || emojie="${message_caption}"
            tluser=$(call_api "$tg_bot_token" "$chat_id" "$message_id" "${file_id}" "${emojie}" )
            echo $tluser

        else
            msg="else: https://github.com/SpEcHiDe/Mp4ToWebmBot"
            result=$(curl -s "${tg_base_request_url}/sendMessage" \
                        -d chat_id="${chat_id}" \
                        -d text="${msg}" \
                        -d parse_mode="HTML" \
                        -d reply_to_message_id="${message_id}"
                )
        fi

        tg_last_update_id=$(($tg_last_update_id + 1))
        # store the correct offset
        # for the next iteration
		TG_LAST_UPDATE_ID="${tg_last_update_id}"
		echo $TG_LAST_UPDATE_ID
    done
}

# call the main function,
# to process updates
moin_function
