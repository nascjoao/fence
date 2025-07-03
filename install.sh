#!/bin/sh
set -e

echo "🔧 Installing 🚧 FENCE..."

INSTALL_PATH="/usr/local/bin/fence"
LIB_PATH="/usr/local/lib/fence"
TMP_DIR=$(mktemp -d)
REPO="nascjoao/fence"
VERSION=$(curl -s https://raw.githubusercontent.com/$REPO/main/VERSION)
TARBALL_URL="https://github.com/$REPO/releases/download/v$VERSION/fence-$VERSION.tar.gz"

if ! curl --head --silent --fail "$TARBALL_URL" > /dev/null; then
  echo "❌ Release tarball not found at $TARBALL_URL"
  exit 1
fi

echo "⬇️  Downloading FENCE v$VERSION..."
curl -sSL "$TARBALL_URL" | tar -xz -C "$TMP_DIR"

if [ "$(id -u)" -ne 0 ]; then
  echo "⚠️  Administrator permissions required to install to $INSTALL_PATH and $LIB_PATH."
  echo "👉 Running with sudo..."
  
  echo "📁 Copying libraries to $LIB_PATH"
  sudo mkdir -p "$LIB_PATH"
  sudo cp -r "$TMP_DIR/fence/lib/"* "$LIB_PATH/"
  
  echo "📂 Copying executable to $INSTALL_PATH"
  sudo cp "$TMP_DIR/fence/bin/fence.sh" "$INSTALL_PATH"
  sudo chmod +x "$INSTALL_PATH"
else
  echo "📁 Copying libraries to $LIB_PATH"
  mkdir -p "$LIB_PATH"
  cp -r "$TMP_DIR/fence/lib/"* "$LIB_PATH/"
  
  echo "📂 Copying executable to $INSTALL_PATH"
  cp "$TMP_DIR/fence/bin/fence.sh" "$INSTALL_PATH"
  chmod +x "$INSTALL_PATH"
fi

rm -rf "$TMP_DIR"

echo ""
echo "🚧 FENCE"
echo "✅ Successfully installed version $VERSION!"
echo ""
echo "➡️  You can now run it with the command: fence"
