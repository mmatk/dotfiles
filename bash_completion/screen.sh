# bash completion for screen

have screen || return

_screen_sessions()
{
    local sessions=( $( command screen -ls | sed -ne \
        's|^\t\{1,\}\([0-9]\{1,\}\.[^\t]\{1,\}\).*'"$1"'.*$|\1|p' ) )
    if [[ $cur == +([0-9])?(.*) ]]; then
        # Complete sessions including pid prefixes
        COMPREPLY=( $( compgen -W '${sessions[@]}' -- "$cur" ) )
    else
        # Create unique completions, dropping pids where possible
        local -A res
        local i tmp
        for i in ${sessions[@]}; do
            res[${i/#+([0-9])./}]+=" $i"
        done
        for i in ${!res[@]}; do
            [[ ${res[$i]} == \ *\ * ]] && tmp+=" ${res[$i]}" || tmp+=" $i"
        done
        COMPREPLY=( $( compgen -W '$tmp' -- "$cur" ) )
    fi
} &&
_screen()
{
    local cur prev words cword
    _init_completion || return

    if ((cword > 2)); then
        case ${words[cword-2]} in
            -[dD])
                _screen_sessions
                return 0
                ;;
        esac
    fi

    local i
    for (( i=1; i <= cword; i++ )); do
        case ${words[i]} in
            -r|-R|-d|-D|-x|-s|-c|-T|-e|-h|-p|-S|-t)
                (( i++ ))
                continue
                ;;
            -*)
                continue
                ;;
        esac

        _command_offset $i
        return
    done

    case $prev in
        -[rR])
            # list detached
            _screen_sessions 'Detached'
            return 0
            ;;
        -[dD])
            # list attached
            _screen_sessions 'Attached'
            return 0
            ;;
        -x)
            # list both
            _screen_sessions
            return 0
            ;;
        -s)
            _shells
            return 0
            ;;
        -c)
            _filedir
            return 0
            ;;
        -T)
            _terms
            return 0
            ;;
        -e|-h|-p|-S|-t)
            return 0
            ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-a -A -c -d -D -e -f -fn -fa -h -i -ln \
            -list -L -m -O -p -q -r -R -s -S -t -T -U -v -wipe -x -X --help \
            --version' -- "$cur" ) )
    fi
} &&
complete -F _screen screen

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh
