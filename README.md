# 🚧 FENCE — FENCE Ensures Nothing Crosses Edges
FENCE is a command-line tool that helps you ensure that your code changes do not exceed a specified line limit when compared to a base branch. It is particularly useful for maintaining code quality and preventing large, unwieldy pull requests.

## 📦 Installation
> macOS e Linux

```bash
curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/install.sh | sh
```

## 🚀 Usage

```bash
fence [base-branch] [-l limit] [-s successMessage] [-f failMessage]
```

### Examples:

```bash
fence                     # Compares with `main` branch within the default limit: 250
fence develop             # Compares with `develop` branch within the default limit: 250
fence develop -l 100      # Compares with `develop` branch with a limit of 100 lines
```

> FYI: FENCE ignores lock files, such as `package-lock.json`, `yarn.lock`, and `pnpm-lock.yaml`.

### Customizing Messages

```bash
fence \
  -s "✅ Alright! Just {total} lines, limit is {limit}" \
  -f "❌ Oh no! {total} lines, limit is {limit}"
```

## ⚙️ Persisting Configuration

You can set preferred settings for limit, success, and failure messages with environment variables:

```bash
export FENCE_LIMIT=300
export FENCE_SUCCESS="✅ Inside limit! {total} lines, limit is {limit}"
export FENCE_FAIL="❌ Over the limit! {total} lines, limit is {limit}"
```

To keep these settings persistent across sessions, add them to your shell configuration file (e.g., `~/.bashrc`, `~/.zshrc`):

For example, if you're using `zsh`, you can add the following lines to your `~/.zshrc`:
```bash
echo 'export FENCE_LIMIT=300' >> ~/.zshrc
echo 'export FENCE_SUCCESS="✅ Inside limit! {total} lines, limit is {limit}"' >> ~/.zshrc
echo 'export FENCE_FAIL="❌ Over the limit! {total} lines, limit is {limit}"' >> ~/.zshrc
```

> These variables will be used by default when running `fence` without command-line arguments

## 🔄 Uninstalling

```bash
curl -sSL https://raw.githubusercontent.com/nascjoao/fence/main/uninstall.sh | sh
```

## 📄 License

This project is licensed under the MIT License.
