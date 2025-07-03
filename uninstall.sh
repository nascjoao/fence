#!/bin/sh

INSTALL_PATH="/usr/local/bin/fence"
LIB_PATH="/usr/local/lib/fence"

if [ -f "$INSTALL_PATH" ] || [ -d "$LIB_PATH" ]; then
  echo "⚠️  Uninstalling FENCE..."

  if [ "$(id -u)" -ne 0 ]; then
    echo "⚠️  It requires administrator permissions to uninstall."
    echo "The command will run with sudo."
    [ -f "$INSTALL_PATH" ] && sudo rm "$INSTALL_PATH"
    [ -d "$LIB_PATH" ] && sudo rm -rf "$LIB_PATH"
  else
    [ -f "$INSTALL_PATH" ] && rm "$INSTALL_PATH"
    [ -d "$LIB_PATH" ] && rm -rf "$LIB_PATH"
  fi

  echo "😢 It is sad to say goodbye. I hope I have been helpful."
  echo "✅ FENCE was uninstalled."
else
  echo "ℹ️  FENCE does not appear to be installed on your system."
  echo "Nothing to uninstall."
fi
