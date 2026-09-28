# Source after compinit to add pinyin, case, and typo fallback matches.

_pinyin_candidates() {
    emulate -L zsh
    local prefix="$1" mode="$2" directory needle candidate match results
    local -a entries names

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

    for candidate in "${entries[@]}"; do
        [[ "$mode" != dirs || -d "$candidate" ]] && names+=( "${candidate:t}" )
    done
    (( ${#names} )) || return 1

    results=$(print -rl -- "${names[@]}" | pinyinmatch -f -- "$needle")
    [[ -n "$results" ]] || results=$(print -rl -- "${names[@]}" | pinyinmatch -fi -- "$needle")
    [[ -n "$results" ]] || results=$(print -rl -- "${names[@]}" | pinyinmatch -T -- "$needle" | head -n 8)
    [[ -n "$results" ]] || results=$(print -rl -- "${names[@]}" | pinyinmatch -t -- "$needle" | head -n 8)
    [[ -n "$results" ]] || return 1

    while IFS= read -r match; do
        [[ -n "$match" ]] || continue
        if [[ "$prefix" == */* ]]; then
            print -r -- "$directory/$match"
        else
            print -r -- "$match"
        fi
    done <<< "$results"
}

_pinyin_complete() {
    local mode=files
    local -a matches
    (( CURRENT > 1 )) || return 1
    [[ "${words[1]}" == cd ]] && mode=dirs
    matches=( "${(@f)$(_pinyin_candidates "$PREFIX" "$mode")}" )
    (( ${#matches} )) || return 1
    compadd -U -f -- "${matches[@]}"
    if (( ${#matches} > 1 )); then
        compstate[insert]=menu
    fi
}

if (( ! $+functions[compdef] )); then
    autoload -Uz compinit
    compinit
fi

zmodload -i zsh/complist
if ! zstyle -a ':completion:*' menu _pinyin_menu_style; then
    zstyle ':completion:*' menu select=2
fi
unset _pinyin_menu_style

local -a _pinyin_completers
zstyle -a ':completion:*' completer _pinyin_completers || _pinyin_completers=( _complete )
if (( ${_pinyin_completers[(Ie)_pinyin_complete]} == 0 )); then
    zstyle ':completion:*' completer "${_pinyin_completers[@]}" _pinyin_complete
fi
unset _pinyin_completers
