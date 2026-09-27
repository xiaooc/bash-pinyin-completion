# bash-pinyin-completion

为 Bash 和 Zsh 添加中文文件名的拼音补全。支持拼音首字母、完整拼音和多音字；需要 UTF-8 环境。

## 获取与编译

需要 C 编译器和 `make`。macOS 安装 Xcode 命令行工具即可，无需 Homebrew。

```sh
git clone https://github.com/xiaooc/bash-pinyin-completion.git
cd bash-pinyin-completion
make
```

## macOS：Zsh

Zsh 不需要 `bash-completion`。默认安装到 `~/.local`，无需 Homebrew 或管理员权限：

```sh
make install-zsh
```

确保 `~/.zshrc` 中的 `PATH` 包含 `~/.local/bin`，并在 `compinit` 之后加载脚本：

```zsh
export PATH="$HOME/.local/bin:$PATH"
autoload -Uz compinit
compinit
source "$HOME/.local/share/bash-pinyin-completion/pinyin_completion.zsh"
```

如果已经调用过 `compinit`，保留现有调用，只需在其后加入 `source` 行。重新打开 Zsh 后，普通补全没有匹配时会尝试拼音匹配；`cd` 只补全目录。

### 可选：安装到 Homebrew 前缀

如果已经使用 Homebrew，也可以选择它的安装目录；这里仅用 `brew --prefix` 确定前缀：

```sh
make MAC_PREFIX="$(brew --prefix)" install-zsh
```

此时在 `~/.zshrc` 的 `compinit` 之后加载：

```zsh
source "$(brew --prefix)/share/bash-pinyin-completion/pinyin_completion.zsh"
```

安装和卸载应使用同一前缀。默认安装运行 `make uninstall-zsh`；Homebrew 前缀安装运行 `make MAC_PREFIX="$(brew --prefix)" uninstall-zsh`。卸载后还需删除 `~/.zshrc` 中对应的 `source` 行。

## macOS：Bash

Bash 补全需要另行安装并启用 `bash-completion`。安装目录应与 `bash-completion` 的前缀一致，通过 `MAC_PREFIX` 指定。例如使用 Homebrew 和 macOS 自带的 Bash 3.2：

```sh
brew install bash-completion
make MAC_PREFIX="$(brew --prefix)" install
```

在 `~/.bash_profile` 中加载 Homebrew 的 `bash-completion`：

```bash
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
```

使用其他安装方式时，将 `MAC_PREFIX` 设为实际前缀，例如 `make MAC_PREFIX=/opt/local install`。卸载时运行相同前缀的 `make MAC_PREFIX=... uninstall`。

## Linux：Bash

安装 `bash-completion` 后运行：

```sh
sudo make install
```

重新打开对应的 shell 后即可使用拼音补全。
