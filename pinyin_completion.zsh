# Source this file after compinit to add pinyin matches when normal Zsh completion has none.

_pinyin_candidates() {
    emulate -L zsh
    local prefix="$1" mode="$2" directory needle candidate match
    local -a entries

    [[ -n "$prefix" ]] || return 1
    if [[ "$prefix" == */* ]]; then
        directory="${prefix%/*}"
        needle="${prefix##*/}"
        [[ -n "$directory" ]] || directory=/
    else
        directory=.
        needle="$prefix"
    fi
    [[ -n "$needle" && -d "$directory" ]] || return 1

    entries=( "$directory"/*(N) "$directory"/.*(N) )
    (( ${#entries} )) || return 1

    while IFS= read -r match; do
        [[ -n "$match" ]] || continue
        if [[ "$prefix" == */* ]]; then
            print -r -- "$directory/$match"
        else
            print -r -- "$match"
        fi
    done < <(
        for candidate in "${entries[@]}"; do
            [[ "$mode" != dirs || -d "$candidate" ]] && print -r -- "${candidate:t}"
        done | pinyinmatch -f -- "$needle"
    )
}

_pinyin_complete() {
    local mode=files
    local -a matches
    (( CURRENT > 1 )) || return 1
    [[ "${words[1]}" == cd ]] && mode=dirs
    matches=( "${(@f)$(_pinyin_candidates "$PREFIX" "$mode")}" )
    (( ${#matches} )) || return 1
    compadd -U -f -- "${matches[@]}"
}

if (( ! $+functions[compdef] )); then
    autoload -Uz compinit
    compinit
fi

local -a _pinyin_completers
zstyle -a ':completion:*' completer _pinyin_completers || _pinyin_completers=( _complete )
if (( ${_pinyin_completers[(Ie)_pinyin_complete]} == 0 )); then
    zstyle ':completion:*' completer "${_pinyin_completers[@]}" _pinyin_complete
fi
unset _pinyin_completers
