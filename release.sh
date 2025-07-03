#!/bin/sh
set -e

VERSION=$(cat VERSION)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TARBALL="build/fence-$VERSION.tar.gz"

echo "🚀 Starting release process for version $VERSION"

if ! command -v gh >/dev/null 2>&1; then
  echo "❌ GitHub CLI (gh) is not installed or not in PATH."
  exit 1
fi

if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "❌ Release must be done from 'main' branch, current is '$CURRENT_BRANCH'."
  exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "❌ Working directory is dirty. Please commit or stash changes before releasing."
  exit 1
fi

git fetch origin
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "✅ Local branch is up-to-date with remote."
elif [ "$LOCAL" = "$BASE" ]; then
  echo "❌ Local branch is behind remote. Please pull changes."
  exit 1
elif [ "$REMOTE" = "$BASE" ]; then
  echo "❌ Local branch is ahead of remote. Please push your commits."
  exit 1
else
  echo "❌ Local and remote branches have diverged. Please reconcile."
  exit 1
fi

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "❌ Tag v$VERSION already exists locally."
  exit 1
fi

if git ls-remote --tags origin | grep -q "refs/tags/v$VERSION$"; then
  echo "❌ Tag v$VERSION already exists on remote."
  exit 1
fi

echo "🧪 Running tests..."
make test

echo "📦 Building distribution package..."
make build

if [ ! -f "$TARBALL" ]; then
  echo "❌ Build failed: $TARBALL not found."
  exit 1
fi

read -p "You are about to release version $VERSION from branch $CURRENT_BRANCH. Continue? (yes/no) " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "❌ Release aborted."
  exit 1
fi

echo "🔖 Creating git tag v$VERSION..."
git tag -a "v$VERSION" -m "Release v$VERSION"
git push origin "v$VERSION"

echo "🏷 Creating GitHub release..."
gh release create "v$VERSION" "$TARBALL" --title "v$VERSION" --notes "Release v$VERSION"

echo "✅ Release v$VERSION created successfully!"
