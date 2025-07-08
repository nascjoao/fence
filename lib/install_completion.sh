#!/bin/sh

install_completion() {
  set -eu

  FENCE_ROOT=$(cd "$(dirname "$0")" && pwd)
  LIB_DIR="${FENCE_LIB_PATH:-/usr/local/lib/fence}"
  COMPLETION_DIR="$LIB_DIR/completion"

  SHELL_NAME=$(basename "${SHELL:-unknown}")

  echo "🔧 Detecting shell: $SHELL_NAME"

  case "$SHELL_NAME" in
    bash)
      TARGET="$HOME/.bash_completion.d"
      mkdir -p "$TARGET"
      cp "$COMPLETION_DIR/fence.bash" "$TARGET/fence.bash"

      if ! grep -q "fence.bash" "$HOME/.bashrc" 2>/dev/null; then
        echo "source $TARGET/fence.bash" >> "$HOME/.bashrc"
        echo "✅ Bash completion successfully installed."
        echo "ℹ️  Run 'source ~/.bashrc' or open a new terminal to activate."
      else
        echo "✅ Bash completion already configured."
      fi
      ;;

    zsh)
      TARGET="$HOME/.zsh/completion"
      mkdir -p "$TARGET"
      cp "$COMPLETION_DIR/_fence.zsh" "$TARGET/_fence"

      if ! grep -q "$TARGET" "$HOME/.zshrc" 2>/dev/null; then
        echo "fpath=($TARGET \$fpath)" >> "$HOME/.zshrc"
        echo "autoload -Uz _fence && compdef _fence fence" >> "$HOME/.zshrc"
        echo "✅ Zsh completion successfully installed."
        echo "ℹ️  Run 'source ~/.zshrc' or open a new terminal to activate."
      else
        echo "✅ Zsh completion already configured."
      fi
      ;;

    fish)
      TARGET="$HOME/.config/fish/completions"
      mkdir -p "$TARGET"
      cp "$COMPLETION_DIR/fence.fish" "$TARGET/fence.fish"
      echo "✅ Fish completion successfully installed."
      echo "ℹ️  Run 'source ~/.config/fish/config.fish' or open a new terminal to activate."
      ;;

    *)
      echo "❌ Shell not supported: $SHELL_NAME"
      echo "⚠️ Automatic support exists only for Bash, Zsh, and Fish."
      ;;
  esac
}
