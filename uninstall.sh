#!/bin/sh

INSTALL_PATH="/usr/local/bin/fence"

if [ -f "$INSTALL_PATH" ]; then
  sudo rm "$INSTALL_PATH"
  echo "It is sad to say goodbye. I hope I have been helpful."
  echo "FENCE was uninstalled."
else
  echo "It seems that FENCE is not installed on your system."
  echo "Please check the installation path or install it first."
  echo "FENCE was not found to uninstall."
fi
