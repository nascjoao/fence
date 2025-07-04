# 🚧 FENCE — FENCE Ensures Nothing Crosses Edges

FENCE is a command-line tool that helps you ensure that your code changes do not exceed a specified line limit when compared to a base branch. It is particularly useful for maintaining code quality and preventing large, unwieldy pull requests.

## Index  
- [▶️ Quick Demonstration](#-quick-demonstration)  
- [📦 Installation](#-installation)  
- [🚀 Usage](#-usage)  
  - [Examples](#examples)  
  - [Customizing Messages](#customizing-messages)  
  - [Reporting Issues](#reporting-issues)  
- [⚙️ Persisting Configuration](#-persisting-configuration)  
- [🧩 GitHub Action](#-github-action)  
  - [✅ Basic usage](#-basic-usage)  
  - [⚙️ Customizing the action](#-customizing-the-action)  
- [🔄 Uninstalling](#-uninstalling)  
- [📄 License](#-license)  

## ▶️ Quick Demonstration  
https://github.com/user-attachments/assets/7b79aed2-1fd7-42d4-a856-d36f334afe2d  

## 📦 Installation  
> macOS and Linux  

```bash
curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/install.sh | sh
```

## 🚀 Usage  

```bash
fence [base-branch] [options]
```

### Options:

- `-l`, `--limit <number>`    Set max allowed modified lines (default: 250)  
- `-s`, `--success <message>`  Custom success message (use `{total}` and `{limit}`)  
- `-f`, `--fail <message>`    Custom fail message (use `{total}` and `{limit}`)  
- `-r`, `--remote`        Compare against remote tracking branch (e.g., `origin/main`)  
- `-n`, `--remote-name <name>` Set remote name (default: `origin`)  
- `-k`, `--skip-update`      Skip update check  
- `-u`, `--update`         Check for updates  
- `-v`, `--version`        Show version  
- `-h`, `--help`          Show help screen  
- `-b`, `--bug-report`     Open GitHub issue pre-filled for reporting a bug  
- `-g`, `--suggest`       Open GitHub issue pre-filled for feature suggestion  

### Important: Default branch  
If no base branch is specified, `fence` assumes `main` by default.

### Remote mode (`-r | --remote`)  
When `-r` is provided, `fence` compares your current local branch against its remote counterpart (e.g., `origin/main` or `origin/feature-branch`).  

- Without `-r`: compares changes against the specified or default **local** branch.  
- With `-r`: compares changes against the remote tracking branch.  

You can set the remote name with `-n` or `--remote-name` (default is `origin`):

```bash
fence -r -n upstream
```

Or set it via the environment variable:

```bash
export FENCE_REMOTE_NAME=upstream
```

### Examples

```bash
fence                          # Compares with `main` branch within the default limit: 250
fence develop                  # Compares with `develop` branch within the default limit
fence develop -l 100           # Sets custom limit
fence -r                       # Compares against origin/main
fence develop -r              # Compares against origin/develop
fence -b                       # Opens GitHub issue to report a bug
fence -g                       # Opens GitHub issue to suggest an idea
```

> FENCE ignores lock files like `package-lock.json`, `yarn.lock`, and `pnpm-lock.yaml`.

### Customizing Messages

```bash
fence \
  -s "✅ All good: {total} lines changed, within {limit}" \
  -f "❌ Too many changes: {total} lines, max allowed is {limit}"
```

### Reporting Issues

FENCE makes it easy to contribute feedback:

- Run `fence -b` to open a **bug report** template with system info prefilled.
- Run `fence -g` to open a **suggestion** template to propose improvements.

## ⚙️ Persisting Configuration

Set environment variables to define defaults:

```bash
export FENCE_SUCCESS="✅ Inside limit! {total} lines, limit is {limit}"
export FENCE_FAIL="❌ Over the limit! {total} lines, limit is {limit}"
export FENCE_LIMIT=300
export FENCE_DEFAULT_BRANCH="develop"
export FENCE_REMOTE_NAME="upstream"
```

To persist these across terminal sessions, add them to your shell config (e.g., `~/.bashrc`, `~/.zshrc`):

```bash
echo 'export FENCE_LIMIT=300' >> ~/.zshrc
```

## 🧩 GitHub Action

You can use FENCE to block large PRs in GitHub Actions.

### ✅ Basic usage

`.github/workflows/fence.yml`:

```yaml
name: FENCE

on:
  pull_request:

jobs:
  check-size:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run FENCE
        uses: nascjoao/fence@v0
```

### ⚙️ Customizing the action

```yaml
      - name: Run FENCE with custom messages
        uses: nascjoao/fence@v0
        with:
          base_branch: develop
          limit: 100
          success_msg: "✅ Within limit: {total} modified lines."
          fail_msg: "❌ Too many changes! Limit is {limit}, but found {total}."
```

## 🔄 Uninstalling

```bash
curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/uninstall.sh | sh
```

## 📄 License

This project is licensed under the MIT License.
