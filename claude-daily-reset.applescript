#!/usr/bin/osascript
-- Claude Daily Reset
-- A script to automatically reset Claude AI token allocation daily
-- GitHub: https://github.com/YourUsername/claude-daily-reset

on run
    -- Create a temporary file for our script
    set tempFile to (do shell script "mktemp /tmp/claude_script.XXXXXX")
    
    -- Content of the bash script to write to the temporary file
    set scriptContent to "#!/bin/bash
# Claude Daily Reset
# This script automatically opens Claude AI to reset daily tokens
# Script runs security checks before proceeding

# ===== CONFIGURATION (MODIFY THESE VALUES) =====
# Define your home Wi-Fi network name - REPLACE THIS WITH YOUR NETWORK NAME
HOME_WIFI=\"YOUR_WIFI_NETWORK_NAME\"

# Define your preferred browser - Options: \"Google Chrome\", \"Safari\", \"Firefox\", \"Microsoft Edge\"
BROWSER=\"Google Chrome\"

# Claude URL - Don't change unless Claude changes their URL structure
CLAUDE_URL=\"https://claude.ai/chats\"

# Wait time in seconds for Claude to initialize (adjust if needed)
INIT_WAIT_TIME=30

# ===== SECURITY CHECKS =====
# Check if connected to home Wi-Fi network
current_wifi=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')

if [[ \"$current_wifi\" != \"$HOME_WIFI\" ]]; then
    echo \"Not connected to home Wi-Fi network. Aborting for security reasons.\"
    exit 1
fi

# ===== STATE PRESERVATION =====
# Check the screen state before execution
screen_state=$(pmset -g powerstate IODisplayWrangler | grep -i \"display wrangler\" | awk '{print $4}')
was_asleep=0

if [[ \"$screen_state\" == \"0\" ]]; then
    was_asleep=1
fi

# Check if screen is locked by password
is_locked=$(osascript -e 'tell application \"System Events\" to return get security preferences\\'s require password to wake')
password_disabled=0

# Disable password only if necessary
if [[ \"$is_locked\" == \"true\" ]]; then
    osascript -e 'tell application \"System Events\" to tell security preferences to set require password to wake to false'
    password_disabled=1
fi

# ===== EXECUTION =====
# Ensure screen stays active during execution
caffeinate -d -i -m -u &
caffeinate_pid=$!

# Open Claude in the browser
open -a \"$BROWSER\" \"$CLAUDE_URL\"

# Wait for the page to load and initialize
sleep $INIT_WAIT_TIME

# Type a character and delete it to ensure initialization
osascript -e 'tell application \"System Events\" to keystroke \".\"'
sleep 1
osascript -e 'tell application \"System Events\" to keystroke (ASCII character 8)' # Backspace

# Close the tab to avoid accumulation
osascript -e 'tell application \"System Events\" to keystroke \"w\" using {command down}'

# ===== RESTORATION =====
# Re-enable password only if we disabled it
if [[ $password_disabled -eq 1 ]]; then
    osascript -e 'tell application \"System Events\" to tell security preferences to set require password to wake to true'
fi

# Stop the caffeinate process
kill $caffeinate_pid

# Put screen back to sleep only if it was asleep before
if [[ $was_asleep -eq 1 ]]; then
    pmset displaysleepnow
fi

# Remove the temporary file
rm \"$0\"
"
    
    -- Write content to the temporary file
    do shell script "cat > " & quoted form of tempFile & " << 'EOFSCRIPT'
" & scriptContent & "
EOFSCRIPT"
    
    -- Make script executable
    do shell script "chmod +x " & quoted form of tempFile
    
    -- Execute script in background without displaying a window
    do shell script tempFile & " > /dev/null 2>&1 &"
    
    return "Claude Daily Reset initiated successfully."
end run