# Claude Token Reset Automation

An invisible automation script for macOS that opens Claude AI at a scheduled time each day to reset token allocation. Features Wi-Fi network verification, security protection, and intelligent state preservation. Works even when your Mac is asleep, with no visible windows during execution.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌟 Features

- 🔄 **Automatic Daily Reset**: Schedule Claude to open at a specific time to reset your tokens
- 🔒 **Security-Focused**: Runs only on your home network with intelligent password handling
- 💤 **State Preservation**: Returns your Mac to its previous state after execution
- 👻 **Invisible Execution**: No visible windows or interruptions
- 🧹 **Self-Cleaning**: Removes temporary files automatically
- 🌐 **Multi-Browser Support**: Works with Chrome, Safari, Firefox, and Edge

## 📋 Prerequisites

- macOS (tested on 11.6.1 and above)
- A browser with Claude AI access
- Calendar app
- Administrator access to configure auto-wake
- Home Wi-Fi network

## 🚀 Quick Installation

### Method 1: Automated Installation Script (Recommended)

The easiest way to install is using the automated installation script:

```bash
curl -s https://raw.githubusercontent.com/nebu0/claude-token-reset-automation/main/install.sh | bash
```

This script will:
- Detect your current Wi-Fi network and browsers
- Ask for your preferences
- Set up the automated schedule
- Configure all necessary permissions
- Create the Calendar event

### Method 2: Direct Script

1. **Download** `claude-token-reset.applescript` from this repository
2. **Open** with Script Editor (AppleScript Editor)
3. **Modify** the Wi-Fi network name and browser settings (lines 16-19)
4. **Save** as a compiled script (.scpt file) in your Applications folder
5. **Set up auto-wake** by running in Terminal: `sudo pmset repeat wakeorpoweron MTWRFSU 8:00:00`
6. **Create** a Calendar event at your desired time with an alert to open the script file

### Method 3: Using Automator

1. **Open Automator** and create a new Application
2. **Add** the "Run AppleScript" action
3. **Paste** the contents of `claude-token-reset.applescript`
4. **Save** the application to your Applications folder
5. **Follow** steps 5-6 from Method 2, but select your Automator app instead

## ⚙️ Customization

### Network and Browser

At the top of the script, you'll find configuration variables:

```bash
# Define your home Wi-Fi network name - REPLACE THIS WITH YOUR NETWORK NAME
# Example: HOME_WIFI="MyHomeWiFi"
HOME_WIFI="YOUR_WIFI_NETWORK_NAME"

# Define your preferred browser - Options: "Google Chrome", "Safari", "Firefox", "Microsoft Edge"
BROWSER="Google Chrome"
```

### Wait Time

If Claude needs more time to initialize properly:

```bash
# Wait time in seconds for Claude to initialize (adjust if needed)
INIT_WAIT_TIME=30
```

## 🛠️ How It Works

The script follows this secure workflow:

1. **Security Check**: Verifies you're on your home Wi-Fi
2. **State Assessment**: Checks if your screen is asleep/locked
3. **Minimum Intervention**: Temporarily disables password only if necessary
4. **Service Access**: Opens Claude in your preferred browser
5. **Token Reset**: Ensures page is properly initialized
6. **Cleanup**: Closes the browser tab and removes temporary files
7. **Restoration**: Returns all settings to their original state

## 🔍 Troubleshooting

### Script Doesn't Run
- Ensure Calendar app is running
- Check that your Mac is plugged in (for auto-wake to work reliably)
- Verify the exact Wi-Fi network name (case-sensitive)

### Permission Issues
- Go to System Preferences > Security & Privacy > Privacy > Accessibility
- Add Script Editor and/or Calendar to the list of authorized apps

### Testing the Script
To test without waiting for the scheduled time:
1. Create a test Calendar event a few minutes in the future
2. Set an alert to open your script
3. Observe if everything works as expected

## ⚠️ Security Note

This script temporarily disables your password requirement only when:
1. You are connected to your specified home Wi-Fi network
2. Your screen was locked with a password
3. For just enough time to initialize Claude (~30 seconds)

All security settings are restored after execution.

## 🗑️ Uninstallation

### Automatic Uninstallation
To completely remove Claude Token Reset Automation:

```bash
curl -s https://raw.githubusercontent.com/nebu0/claude-token-reset-automation/main/uninstall.sh | bash
```

### Manual Uninstallation
1. Remove your Calendar event
2. Cancel the scheduled wake-up: `sudo pmset repeat cancel`
3. Delete the script file

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🗺️ Roadmap

- [ ] Support for multiple Wi-Fi networks
- [ ] Notification options for successful resets
- [ ] Status logging feature
- [ ] Integration with other token-based services
