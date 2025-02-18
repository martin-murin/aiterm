# aiterm - AI Terminal Interface for Linux

## Overview

This simple AI interface for the Linux terminal allows you to interact with an AI model directly from your command line. It leverages the Mistral AI API to process natural language queries and execute commands based on the AI's responses.

## Setup Instructions

1. **Set API Key:**
   - Obtain your API key from Mistral AI.
   - Open the `ai.sh` file and set the `API_KEY` variable with your key.

2. **Make the Script Executable:**
   ```bash
   chmod +x ai.sh
   ```

3. **Install the Script Globally:**
   - Copy the script to a directory in your PATH, such as `/usr/local/bin`:
     ```bash
     sudo cp ai.sh /usr/local/bin/ai
     ```

## Usage Examples

### Check Memory Usage of Brave Browser

```bash
ai how much memory is brave consuming right now in total
```

**AI Response:**
```
AI: `ps -C brave --no-headers -o rss= | awk '{sum+=$1} END {print sum/1024 "MB"}'`
Do you want to run `ps -C brave --no-headers -o rss= | awk '{sum+=$1} END {print sum/1024 "MB"}'`? [Y/n] y
3240.65MB
```

## How It Works

1. **Prompt Handling:**
   - The script reads input from the command line or piped content.
   - It sends this input to the Mistral AI API for processing.

2. **Response Parsing:**
   - The AI's response is parsed to extract any commands.
   - The user is prompted to confirm before executing any commands.

3. **Command Execution:**
   - If the user confirms, the command is executed in the terminal.

## Requirements

- `curl` for making HTTP requests.
- `jq` for parsing JSON responses.

## License

This script is provided under the MIT License. Feel free to modify and distribute it as needed.
