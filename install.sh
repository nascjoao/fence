#!/bin/sh

echo "🔧 Installing 🚧 FENCE..."

INSTALL_PATH="/usr/local/bin/fence"
SCRIPT_URL="https://raw.githubusercontent.com/nascjoao/fence/main/bin/fence.sh"

if [ "$(id -u)" -ne 0 ]; then
  echo "⚠️  It requires administrator permissions to install it in $INSTALL_PATH."
  echo "The command will run with sudo."
  sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_PATH" && sudo chmod +x "$INSTALL_PATH"
else
  curl -sSL "$SCRIPT_URL" -o "$INSTALL_PATH" && chmod +x "$INSTALL_PATH"
fi

if [ $? -eq 0 ]; then
  echo ""
  echo "🚧 FENCE"
  echo "✅ Succesfully installed at $INSTALL_PATH"
  echo ""
  echo "➡️ You can now run it with the command: fence"
else
  echo "❌ Failed to install FENCE. Please check your internet connection or permissions."
  exit 1
fi
