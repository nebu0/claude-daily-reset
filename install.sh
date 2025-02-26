#!/bin/bash
# Claude Daily Reset - Installation Script
# This script automates the installation process for the Claude Daily Reset tool
# GitHub: https://github.com/nebu0/claude-daily-reset

echo "==== Claude Daily Reset - Installation Script ===="
echo "This script will set up the Claude Daily Reset tool for you."
echo ""

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if we're running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ Error: This script is only compatible with macOS systems."
  exit 1
fi

# Create installation directory
INSTALL_DIR="$HOME/Applications/ClaudeDailyReset"
mkdir -p "$INSTALL_DIR"

echo "📁 Created installation directory at: $INSTALL_DIR"

# Get Wi-Fi network name
echo "🔍 Detecting your current Wi-Fi network..."
CURRENT_WIFI=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')

if [ -z "$CURRENT_WIFI" ]; then
  echo "⚠️  Could not detect your Wi-Fi network. Please enter it manually:"
  read -p "> " WIFI_NAME
else
  echo "🌐 Detected Wi-Fi network: $CURRENT_WIFI"
  read -p "Use this Wi-Fi network for the automation? (Y/n): " USE_DETECTED
  if [[ $USE_DETECTED =~ ^[Nn]$ ]]; then
    read -p "Enter your home Wi-Fi network name: " WIFI_NAME
  else
    WIFI_NAME="$CURRENT_WIFI"
  fi
fi

# Determine browser
echo "🌍 Detecting installed browsers..."
BROWSERS=()
BROWSER_PATHS=()

if command_exists "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; then
  BROWSERS+=("Google Chrome")
  BROWSER_PATHS+=("/Applications/Google Chrome.app")
fi

if command_exists "/Applications/Safari.app/Contents/MacOS/Safari"; then
  BROWSERS+=("Safari")
  BROWSER_PATHS+=("/Applications/Safari.app")
fi

if command_exists "/Applications/Firefox.app/Contents/MacOS/firefox"; then
  BROWSERS+=("Firefox")
  BROWSER_PATHS+=("/Applications/Firefox.app")
fi

if command_exists "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"; then
  BROWSERS+=("Microsoft Edge")
  BROWSER_PATHS+=("/Applications/Microsoft Edge.app")
fi

if [ ${#BROWSERS[@]} -eq 0 ]; then
  echo "❌ Error: No compatible browsers found. Please install Chrome, Safari, Firefox, or Edge."
  exit 1
elif [ ${#BROWSERS[@]} -eq 1 ]; then
  SELECTED_BROWSER="${BROWSERS[0]}"
  echo "🌍 Only one browser detected: $SELECTED_BROWSER. Using this browser."
else
  echo "🌍 Multiple browsers detected. Please select your preferred browser:"
  for i in "${!BROWSERS[@]}"; do
    echo "  $((i+1)). ${BROWSERS[$i]}"
  done
  
  read -p "> " BROWSER_CHOICE
  BROWSER_INDEX=$((BROWSER_CHOICE-1))
  
  if [[ $BROWSER_INDEX -lt 0 || $BROWSER_INDEX -ge ${#BROWSERS[@]} ]]; then
    echo "❌ Invalid selection. Using ${BROWSERS[0]} as default."
    SELECTED_BROWSER="${BROWSERS[0]}"
  else
    SELECTED_BROWSER="${BROWSERS[$BROWSER_INDEX]}"
  fi
fi

echo "🌍 Using browser: $SELECTED_BROWSER"

# Ask for wake time
echo "⏰ When would you like Claude to reset tokens each day?"
read -p "Enter time (24-hour format, e.g. 08:00): " RESET_TIME

# Validate time format
if [[ ! $RESET_TIME =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
  echo "⚠️ Invalid time format. Using default time (08:00)."
  RESET_TIME="08:00"
fi

# Extract hour and minute
HOUR=${RESET_TIME%:*}
MINUTE=${RESET_TIME#*:}

# Download the script from GitHub
echo "📥 Downloading the script from repository..."
curl -s https://raw.githubusercontent.com/nebu0/claude-daily-reset/main/claude-daily-reset.applescript > "$INSTALL_DIR/claude-daily-reset.applescript"

# Replace configuration parameters
echo "⚙️ Customizing the script with your preferences..."
sed -i '' "s/HOME_WIFI=\"YOUR_WIFI_NETWORK_NAME\"/HOME_WIFI=\"$WIFI_NAME\"/" "$INSTALL_DIR/claude-daily-reset.applescript"
sed -i '' "s/BROWSER=\"Google Chrome\"/BROWSER=\"$SELECTED_BROWSER\"/" "$INSTALL_DIR/claude-daily-reset.applescript"

# Compile the script
echo "🔧 Compiling the script..."
osacompile -o "$INSTALL_DIR/ClaudeDailyReset.app" "$INSTALL_DIR/claude-daily-reset.applescript"

# Make sure the app is executable
chmod +x "$INSTALL_DIR/ClaudeDailyReset.app/Contents/MacOS/applet"

# Set up auto-wake
echo "⏰ Configuring system to wake daily at $RESET_TIME..."
sudo pmset repeat wakeorpoweron MTWRFSU "$HOUR:$MINUTE:00"

# Create a Calendar event
echo "📅 Creating Calendar event..."
osascript <<EOD
tell application "Calendar"
  try
    tell calendar "Home"
      set newEvent to make new event with properties {summary:"Claude Daily Reset", start date:current date, end date:(current date) + 30 * minutes, recurrence:"FREQ=DAILY"}
      tell newEvent
        make new display alarm at end of display alarms with properties {trigger interval:-1, action:"open file", file name:"$INSTALL_DIR/ClaudeDailyReset.app"}
        set start date to (current date) + ((($HOUR * 60) + $MINUTE) * 60) - ((hours of (current date) * 60 + minutes of (current date)) * 60)
        set end date to (start date) + 30 * minutes
      end tell
    end tell
  on error
    # Try with default calendar if Home calendar doesn't exist
    set defaultCalendar to default calendar
    tell defaultCalendar
      set newEvent to make new event with properties {summary:"Claude Daily Reset", start date:current date, end date:(current date) + 30 * minutes, recurrence:"FREQ=DAILY"}
      tell newEvent
        make new display alarm at end of display alarms with properties {trigger interval:-1, action:"open file", file name:"$INSTALL_DIR/ClaudeDailyReset.app"}
        set start date to (current date) + ((($HOUR * 60) + $MINUTE) * 60) - ((hours of (current date) * 60 + minutes of (current date)) * 60)
        set end date to (start date) + 30 * minutes
      end tell
    end tell
  end try
end tell
EOD

# Request permissions
echo "🔒 Setting up required permissions..."
echo "We need to set up some system permissions. A dialog may appear asking for accessibility permissions."
echo "Please click 'OK' when prompted."

osascript <<EOD
tell application "System Events"
  tell security preferences
    set properties to {require password to wake:true}
  end tell
end tell
EOD

echo "✅ Installation complete! Claude Daily Reset will run daily at $RESET_TIME."
echo "📝 Notes:"
echo "  - Make sure your Mac is connected to power to ensure it wakes reliably"
echo "  - The script will only run when connected to: $WIFI_NAME"
echo "  - You can find the installation at: $INSTALL_DIR"
echo "  - If you need to uninstall, run: bash <(curl -s https://raw.githubusercontent.com/nebu0/claude-daily-reset/main/uninstall.sh)"
echo ""
echo "Would you like to test the script now? (y/N)"
read -p "> " TEST_NOW

if [[ $TEST_NOW =~ ^[Yy]$ ]]; then
  echo "🧪 Running the script for testing..."
  open "$INSTALL_DIR/ClaudeDailyReset.app"
fi

exit 0