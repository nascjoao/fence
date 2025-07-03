#!/bin/sh

echo "🔧 Installing 🚧 FENCE..."

INSTALL_PATH="/usr/local/bin/fence"
REPO_URL="https://raw.githubusercontent.com/wisley7l/fence/main"
SCRIPT_URL="$REPO_URL/bin/fence.sh"
FENCE_DIR="/usr/local/bin/.fence"

echo "FENCE_DIR: $FENCE_DIR"
echo "REPO_URL: $REPO_URL"
echo "SCRIPT_URL: $SCRIPT_URL"

download_files() {
  local isSudo=$1
  local sudo=""
  
  if [ "$isSudo" = "true" ]; then
    sudo="sudo"
  fi
  
  $sudo curl -sSL "$SCRIPT_URL" -o "$INSTALL_PATH" && $sudo chmod +x "$INSTALL_PATH"
  
  $sudo mkdir -p "$FENCE_DIR"
  if [ ! -d "$FENCE_DIR" ]; then
    echo "❌ Erro: Falha ao criar o diretório $FENCE_DIR"
    echo "   Verifique as permissões e tente novamente."
    exit 1
  fi
  
  $sudo chmod 755 "$FENCE_DIR"
  $sudo curl -sSL "$REPO_URL/lib/common.sh" -o "$FENCE_DIR/common.sh"
  $sudo curl -sSL "$REPO_URL/lib/help.sh" -o "$FENCE_DIR/help.sh"
  $sudo curl -sSL "$REPO_URL/lib/remote.sh" -o "$FENCE_DIR/remote.sh"
  $sudo curl -sSL "$REPO_URL/lib/local.sh" -o "$FENCE_DIR/local.sh"
}

if [ "$(id -u)" -ne 0 ]; then
  echo "⚠️  It requires administrator permissions to install it in $INSTALL_PATH."
  echo "The command will run with sudo."
  download_files true
else
  download_files false
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
