## 特性

  * 支持拼音首字母匹配和完全匹配
  * 支持多音字匹配
  * 仅支持UTF-8编码环境

## 安装

本项目支持 Bash 和 Zsh 的拼音文件补全。

    git clone https://github.com/xiaooc/bash-pinyin-completion.git
    cd bash-pinyin-completion
    make

### macOS：Zsh

Zsh 无需安装 bash-completion。编译后运行：

    make install-zsh

在 `~/.zshrc` 的 `compinit` 之后加入：

    source "$(brew --prefix)/share/bash-pinyin-completion/pinyin_completion.zsh"

新开 Zsh 终端后，普通补全没有匹配时会尝试拼音匹配；`cd` 只补全目录。卸载可运行 `make uninstall-zsh`，并删除上面的 `source` 行。

### macOS：Bash（Homebrew）

macOS 自带 Bash 3.2，可安装对应的 bash-completion：

    brew install bash-completion
    printf '%s\n' '[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"' >> ~/.bash_profile
    make install

安装目录会使用 `brew --prefix`，Apple Silicon 通常为 `/opt/homebrew`，Intel Mac 通常为 `/usr/local`。如果使用其他前缀，可传入 `MAC_PREFIX`，例如 `make MAC_PREFIX=/opt/local install`。卸载时使用相同前缀：`make uninstall`。

### Linux

安装 bash-completion 后运行：

    sudo make install

新开一个 Bash 终端后即可使用拼音补全。
