#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
make -s pinyinmatch

test_dir=$(mktemp -d /private/tmp/pinyin-bash-test.XXXXXX)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/Download" "$test_dir/work" "$test_dir/WorkBuddy" "$test_dir/中文目录"
ten_hanzi='中中中中中中中中中中'
mkdir -p "$test_dir/$ten_hanzi"

script="$PWD/pinyin_completion"
export PATH="$PWD:$PATH"
_expand() { :; }
_get_comp_words_by_ref() { printf -v "$1" '%s' "$TEST_CUR"; }
_comp_compgen_filedir() {
    COMPREPLY=()
    [[ "$TEST_CUR" == work ]] && COMPREPLY=(./work)
    [[ "$TEST_CUR" == wok && "${TEST_NATIVE:-}" == 1 ]] && COMPREPLY=(./native)
    return 0
}
source ./pinyin_completion
cd "$test_dir"

TEST_CUR=down
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./Download ]] || { echo "case fallback: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_CUR="'down"
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./Download ]] || { echo "single-quoted path: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_CUR='"down'
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./Download ]] || { echo "double-quoted path: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_CUR=wok
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./work ]] || { echo "typo fallback: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_CUR=zw
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./中文目录 ]] || { echo "pinyin matching changed: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_CUR=zzzzzzzzzz
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == "./$ten_hanzi" ]] || {
    printf 'two-digit match count corrupted candidate: %q\n' "${COMPREPLY[*]}" >&2
    exit 1
}

TEST_CUR=work
COMPREPLY=(./work)
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./work ]] || { echo "native match should have priority: ${COMPREPLY[*]}" >&2; exit 1; }

TEST_NATIVE=1
TEST_CUR=wok
COMPREPLY=()
_comp_compgen_filedir -d
[[ "${COMPREPLY[*]}" == ./native ]] || { echo "typo should not follow a native match: ${COMPREPLY[*]}" >&2; exit 1; }

legacy_result=$(bash -c '
    _expand() { :; }
    _get_comp_words_by_ref() { printf -v "$1" "%s" wok; }
    _filedir() { COMPREPLY=(); }
    source "$1"
    cd "$2"
    COMPREPLY=()
    _filedir -d
    printf "%s\n" "${COMPREPLY[@]}"
' bash "$script" "$test_dir")
[[ "$legacy_result" == ./work ]] || { echo "legacy Bash hook: $legacy_result" >&2; exit 1; }
