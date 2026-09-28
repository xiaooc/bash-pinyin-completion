# bash-pinyin-completion

为 Bash 和 Zsh 补全中文文件名。需要 UTF-8 环境、C 编译器和 `make`；macOS 使用 Xcode 命令行工具即可。

## 补全规则

普通文件名和拼音（首字母、全拼、多音字）优先。两者都没有结果时，依次尝试忽略英文字母大小写的前缀、英文文件名 typo；找到结果后不再尝试下一种匹配。

例如 `cd down` 可以补到 `Download`；`cd wok` 可以补到 `work`。typo 支持一次插入、删除、替换或相邻字母交换，至少输入 3 个英文字母；完整文件名的匹配优先于较长文件名的前缀匹配，最多显示 8 个候选。

## 编译

```sh
git clone https://github.com/xiaooc/bash-pinyin-completion.git
cd bash-pinyin-completion
make
```

## 安装

### macOS：Zsh

默认安装到 `~/.local`，不需要 `bash-completion` 或管理员权限：

```sh
make install-zsh
```

在 `~/.zshrc` 中，确保 `~/.local/bin` 在 `PATH` 中，并在 `compinit` 后加载脚本：

```zsh
export PATH="$HOME/.local/bin:$PATH"
autoload -Uz compinit
compinit
source "$HOME/.local/share/bash-pinyin-completion/pinyin_completion.zsh"
```

如果已调用 `compinit`，只需在其后增加 `source` 行。`cd` 的补齐候选仅包含目录。

使用 Homebrew 前缀时，安装和加载都要使用该前缀：

```sh
make MAC_PREFIX="$(brew --prefix)" install-zsh
```

```zsh
source "$(brew --prefix)/share/bash-pinyin-completion/pinyin_completion.zsh"
```

### macOS：Bash

先安装并启用 `bash-completion`。安装前缀必须与它一致，例如：

```sh
brew install bash-completion
make MAC_PREFIX="$(brew --prefix)" install
```

在 `~/.bash_profile` 中加载 `bash-completion`：

```bash
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
```

其他安装方式可指定实际前缀，例如 `make MAC_PREFIX=/opt/local install`。支持 macOS 自带的 Bash 3.2。

### Linux：Bash

安装 `bash-completion` 后运行：

```sh
sudo make install
```

安装后重新打开对应的 Shell。

## 多候选选择

Zsh 默认在有多个候选时按 Tab 显示选择菜单。方向键切换、回车确认候选，再回车执行命令。该菜单设置也用于其他 Zsh 补全；已有的自定义菜单设置会保留。如需方向键选择，可在 `~/.zshrc` 设置 `zstyle ':completion:*' menu select=2`。

Bash 会列出多个候选。如需反复按 Tab 轮流选择，可在 Bash 配置中加入 `bind '"\t": menu-complete'`；这会改变所有 Bash 命令的 Tab 行为。

## 卸载

Zsh 默认安装运行 `make uninstall-zsh`；使用自定义前缀时运行 `make MAC_PREFIX=... uninstall-zsh`。Bash 在 macOS 上以安装时相同的 `MAC_PREFIX` 运行 `make uninstall`；Linux 上运行 `sudo make uninstall`。最后删除 Shell 配置中添加的加载行。
