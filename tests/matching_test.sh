#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
make -s pinyinmatch

names=$'Download\nwork\nworker\n中文目录\n'

result=$(printf '%s' "$names" | ./pinyinmatch -i -- down)
[[ "$result" == Download ]] || { echo "case match: expected Download, got '$result'" >&2; exit 1; }

result=$(printf '%s' "$names" | ./pinyinmatch -t -- wok)
[[ "$result" == $'work\nworker' ]] || { echo "typo match: expected work and worker, got '$result'" >&2; exit 1; }

result=$(printf '%s' "$names" | ./pinyinmatch -t -- wo)
[[ -z "$result" ]] || { echo "short typo query should not match" >&2; exit 1; }

result=$(printf '%s' "$names" | ./pinyinmatch -t -- zw)
[[ -z "$result" ]] || { echo "pinyin should not receive ASCII typo matching" >&2; exit 1; }

result=$(printf 'abceXYZ\n' | ./pinyinmatch -t -- abcde)
[[ "$result" == abceXYZ ]] || { echo "deletion in a longer filename prefix was missed" >&2; exit 1; }

result=$(printf 'WorkBuddy\nwork\n' | ./pinyinmatch --typo-whole -- wok)
[[ "$result" == work ]] || { echo "whole-name typo match should prefer work" >&2; exit 1; }
