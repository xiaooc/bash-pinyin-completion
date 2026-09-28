#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
make -s pinyinmatch

test_dir=$(mktemp -d /private/tmp/pinyin-zsh-test.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/中文目录" "$test_dir/子目录" "$test_dir/Download" "$test_dir/work" "$test_dir/WorkBuddy"
touch "$test_dir/中文 文件.txt" "$test_dir/子目录/中国.txt"

script="$PWD/pinyin_completion.zsh"
export PATH="$PWD:$PATH"

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates zw files' zsh "$script" "$test_dir")
[[ "$results" == *'中文目录'* ]] || { echo "missing Chinese directory" >&2; exit 1; }
[[ "$results" == *'中文 文件.txt'* ]] || { echo "missing file with spaces" >&2; exit 1; }

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates zw dirs' zsh "$script" "$test_dir")
[[ "$results" == '中文目录' ]] || { echo "directory mode returned: $results" >&2; exit 1; }

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates 子目录/zg files' zsh "$script" "$test_dir")
[[ "$results" == '子目录/中国.txt' ]] || { echo "nested completion returned: $results" >&2; exit 1; }

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates down dirs' zsh "$script" "$test_dir")
[[ "$results" == Download ]] || { echo "case fallback: expected Download, got '$results'" >&2; exit 1; }

results=$(zsh -fc 'source "$1"; cd "$2"; _pinyin_candidates wok dirs' zsh "$script" "$test_dir")
[[ "$results" == work ]] || { echo "typo fallback: expected work, got '$results'" >&2; exit 1; }

mkdir -p "$test_dir/menu/work" "$test_dir/menu/won" "$test_dir/menu/wow"
if command -v expect >/dev/null; then
    expect tests/zsh_menu_test.exp "$script" "$test_dir/menu" "$test_dir"
else
    echo "Skipping interactive Zsh menu test (expect not installed)" >&2
fi

zsh -fc 'autoload -Uz compinit; compinit -C; source "$1"; source "$1"; zstyle -a ":completion:*" completer values; [[ "${(j:,:)values}" == _complete,_pinyin_complete ]]' zsh "$script"
zsh -fc 'zstyle ":completion:*" menu no; source "$1"; zstyle -a ":completion:*" menu values; [[ "${(j:,:)values}" == no ]]' zsh "$script"

default_install=$(make -n install-zsh)
if [[ "$default_install" != *"$HOME/.local/bin/pinyinmatch"* ]] ||
   [[ "$default_install" != *"$HOME/.local/share/bash-pinyin-completion/pinyin_completion.zsh"* ]]; then
    echo "Zsh installation does not default to ~/.local" >&2
    exit 1
fi

make -s MAC_PREFIX="$test_dir/prefix" install-zsh
test -x "$test_dir/prefix/bin/pinyinmatch"
test -f "$test_dir/prefix/share/bash-pinyin-completion/pinyin_completion.zsh"
make -s MAC_PREFIX="$test_dir/prefix" uninstall-zsh
test ! -e "$test_dir/prefix/bin/pinyinmatch"
test ! -e "$test_dir/prefix/share/bash-pinyin-completion/pinyin_completion.zsh"
