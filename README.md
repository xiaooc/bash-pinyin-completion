## 特性

  * 支持拼音首字母匹配和完全匹配
  * 支持多音字匹配
  * 仅支持UTF-8编码环境

## 安装

本项目用于 Bash，需要先安装并启用 bash-completion。

    git clone https://github.com/xiaooc/bash-pinyin-completion.git
    cd bash-pinyin-completion
    make

### macOS（Homebrew）

macOS 自带 Bash 3.2，可安装对应的 bash-completion：

    brew install bash-completion
    printf '%s\n' '[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"' >> ~/.bash_profile
    make install

安装目录会使用 `brew --prefix`，Apple Silicon 通常为 `/opt/homebrew`，Intel Mac 通常为 `/usr/local`。如果使用其他前缀，可传入 `MAC_PREFIX`，例如 `make MAC_PREFIX=/opt/local install`。卸载时使用相同前缀：`make uninstall`。

### Linux

安装 bash-completion 后运行：

    sudo make install

新开一个 Bash 终端后即可使用拼音补全。macOS 默认的 Zsh 不会加载 Bash 补全脚本。
