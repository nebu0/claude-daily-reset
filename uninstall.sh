#!/bin/bash
# Claude Daily Reset - Uninstallation Script
# This script removes all components of the Claude Daily Reset tool
# GitHub: https://github.com/nebu0/claude-daily-reset

echo "==== Claude Daily Reset - Uninstallation Script ===="
echo "This script will remove the Claude Daily Reset automation tool from your system."
echo ""

# Check if we're running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ Error: This script is only compatible with macOS systems."
  exit 1
fi

# Confirm uninstallation
read -p "Are you sure you want to uninstall Claude Daily Reset? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
  echo "Uninstallation cancelled."
  exit 0
fi

# Installation directory
INSTALL_DIR="$HOME/Applications/ClaudeDailyReset"

# Cancel scheduled wake-ups
echo "⏰ Cancelling scheduled wake-ups..."
sudo pmset repeat cancel

# Remove Calendar event
echo "📅 Removing Calendar event..."
osascript <<EOD
tell application "Calendar"
  set eventFound to false
  repeat with cal in calendars
    set eventList to (every event of cal whose summary is "Claude Daily Reset")
    if length of eventList > 0 then
      repeat with theEvent in eventList
        delete theEvent
        set eventFound to true
      end repeat
    end if
  end repeat
  return eventFound
end tell
EOD

CALENDAR_RESULT=$?
if [ $CALENDAR_RESULT -eq 0 ]; then
  echo "  No matching Calendar events found."
else
  echo "  Calendar events removed successfully."
fi

# Remove installation directory
if [ -d "$INSTALL_DIR" ]; then
  echo "📁 Removing installation directory..."
  rm -rf "$INSTALL_DIR"
  echo "  Installation directory removed."
else
  echo "📁 Installation directory not found."
fi

# Check for any remaining files in /tmp
echo "🧹 Cleaning up temporary files..."
rm -f /tmp/claude_script.*

echo "✅ Uninstallation complete! Claude Daily Reset has been removed from your system."
exit 0