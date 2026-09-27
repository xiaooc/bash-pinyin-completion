#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
make -s pinyinmatch

test_dir=$(mktemp -d /private/tmp/pinyin-zsh-test.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/中文目录" "$test_dir/子目录"
touch "$test_dir/中文 文件.txt" "$test_dir/子目录/中国.txt"

script="$PWD/pinyin_completion.zsh"
export PATH="$PWD:$PATH"

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates zw files' zsh "$script" "$test_dir")
[[ "$results" == *'中文目录'* ]]
[[ "$results" == *'中文 文件.txt'* ]]

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates zw dirs' zsh "$script" "$test_dir")
[[ "$results" == '中文目录' ]]

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates 子目录/zg files' zsh "$script" "$test_dir")
[[ "$results" == '子目录/中国.txt' ]]

zsh -fc 'autoload -Uz compinit; compinit -C; source "$1"; source "$1"; zstyle -a ":completion:*" completer values; [[ "${(j:,:)values}" == _complete,_pinyin_complete ]]' zsh "$script"

make -s MAC_PREFIX="$test_dir/prefix" install-zsh
test -x "$test_dir/prefix/bin/pinyinmatch"
test -f "$test_dir/prefix/share/bash-pinyin-completion/pinyin_completion.zsh"
make -s MAC_PREFIX="$test_dir/prefix" uninstall-zsh
test ! -e "$test_dir/prefix/bin/pinyinmatch"
test ! -e "$test_dir/prefix/share/bash-pinyin-completion/pinyin_completion.zsh"
