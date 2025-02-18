#!/bin/bash

# Mistral AI API endpoint and API key
API_ENDPOINT="https://api.mistral.ai/v1/agents/completions"
API_KEY="<your_api_key_here>"
AGENT_ID="ag:dee55b74:20250218:terminal-ai:8e666f3b"

# Function to send a request to Mistral AI API
send_to_mistral() {
    local prompt="$1"
    local response
    local http_code

    # Capture the response and HTTP status code
    response=$(curl -s -w "%{http_code}" -X POST "$API_ENDPOINT" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d '{
            "messages": [{"role": "user", "content": "'"$prompt"'"}],
            "max_tokens": 300,
            "agent_id": "'"$AGENT_ID"'"
        }')

    # Extract the HTTP status code from the response
    http_code="${response: -3}"

    # Remove the HTTP status code from the response body
    response="${response%${http_code}}"

    if [ "$http_code" -ne 200 ]; then
        echo "[Error] Received HTTP status code $http_code" >&2
        echo "[Debug] Raw response: $response" >&2
        return 1
    fi

    echo "$response"
}

# Function to extract and display the command from the AI response
parse_response() {
    local response="$1"
    local message
    local command

    # Check if the response is valid JSON
    if ! echo "$response" | jq empty >/dev/null 2>&1; then
        echo "Error: Invalid JSON response"
        return 1
    fi

    # Extract the message from the response
    message=$(echo "$response" | jq -r '.choices[0].message.content')
    echo "AI: $message"

    # Extract the command from the message using a regular expression
    command=$(echo "$message" | grep -oP '(?<=`)[^`]+(?=`)')

    if [ -n "$command" ]; then
        echo -n "Do you want to run \`$command\`? [Y/n] "
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            eval "$command"
        fi
    fi
}

# Main script
if [ -p /dev/stdin ]; then
    # Read piped input and escape special characters
    content=$(cat | tr '\n' ' ' | sed 's/[^[:print:]]//g' | sed 's/"/\\"/g')
    # Check if there is a prompt provided as an argument
    if [ "$#" -gt 0 ]; then
        prompt="$*"
        full_prompt="Given the following content, $prompt:\n$content"
    else
        full_prompt="Analyze the following content and provide relevant insights or commands:\n$content"
    fi
else
    # Read command-line arguments
    if [ "$#" -lt 1 ]; then
        echo "Usage: $0 <prompt>"
        exit 1
    fi
    prompt="$*"
    full_prompt="$prompt"
fi

# Send the request and capture the response
if ! response=$(send_to_mistral "$full_prompt"); then
    echo "Failed to send request to Mistral AI or received error response."
    exit 1
fi

parse_response "$response"
