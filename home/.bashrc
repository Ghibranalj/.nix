# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

ex() {
    if [[ ! -f $1 ]]; then
        echo "$1 is not a valid file"
        return 1
    fi
    case $1 in
        *.tar.bz2) tar xjvf "$1" ;;
        *.tar.gz) tar xzvf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar x "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *)
            echo "$1 cannot be extracted via ex()"
            return 1
            ;;
    esac
}

[[ -f /usr/share/git/completion/git-prompt.sh ]] && source /usr/share/git/completion/git-prompt.sh

export PS1="\[\033[38;5;6m\]\u\[\033[38;5;8m\]@\[\033[38;5;10m\]\h\[\033[38;5;8m\]-\[\033[38;5;6m\][\[\033[38;5;9m\]\W\[\033[38;5;7m\]\$(__git_ps1 ' (%s) ')\[\033[38;5;6m\]]\[\033[38;5;8m\]\\$ \[\$(tput  sgr0)\]"

#coloured manpages
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export MANPAGER='nvim +Man!'
# export MANPAGER='emacspipe'

alias less=most

VISUAL="vi"
EDITOR="vi"
if command -v lvim >/dev/null ; then
    VISUAL="lvim"
    EDITOR="lvim"
elif command -v nvim >/dev/null ; then
    VISUAL="nvim"
    EDITOR="nvim"
elif command -v vim >/dev/null ; then
    VISUAL="vim"
    EDITOR="vim"
fi

alias grep='grep --color=auto'

alias c=clear

# alias windows10='vbox-ctl -S Windows10'
if command -v virsh &>/dev/null; then
    alias virsh='virsh -c qemu:///system'
    alias windows10='virsh start win10'
fi

alias pickcolor="colorpicker --short --one-shot 2> /dev/null | xclip -sel c "
function nav() {
    dir='.'
    flags=$@
    while [[ $extc -ne 130 ]]; do
        list="$(/bin/exa $flags $dir*/)"
        for l in $list; do
            [[ -d $dir/$l ]] && dirlist="$dirlist $l"
        done
        [[ $dirlist == *'..'* ]] || dirlist=".. $dirlist"

        branch=''
        [[ -d "${dir}/.git" ]] && branch="($(
            cd "$dir"
            git branch | grep '^\*' | cut -d' ' -f2
        ))"

        d="$(echo $dirlist | tr ' ' '\n' | fzf --no-sort --preview="exa -G --color=always --icons --group-directories-first $dir/{}" --prompt="Search $branch: " --no-info)"
        extc=$?
        dir=$dir/$d
        unset dirlist list header flist branch
    done
    cd $dir
    unset extc dir flags
}

function delete() {
    files="$(/bin/ls -a | fzf -m | tr '\n' ' ')"
    [[ $files == "" ]] && return
    rm $@ -v $files
}
function make-homework() {
    if [ $# -eq 0 ]; then
        echo "err: No arguments"
        return 254
    fi
    touch vclj2729_B$1_A{1..4}.tex
}

function ind() {
    $1 &>>~/.app.log &
    disown
}
complete -cf ind

function rename-homework() {
    declare -i i=1
    for f in $(ls . | grep .$2); do
        echo $i
        mv -- "$f" "vclj2729_B$1_A$i.$2"
        i=$((i + 1))
    done
}

function fix-keybind() {
    xkbcomp /home/gibi/.xkbmap $DISPLAY &>/home/gibi/.keybind.log
    # gsettings set org.gnome.settings-daemon.plugins.keyboard active false
}

function clip() {
    echo $1 | xclip -sel c
}

function generate-ssh-github() {

    if ! test -f "${HOME}/.ssh/id_ed25519.pub"; then
        ssh-keygen -t ed25519 -C "24712554+Ghibranalj@users.noreply.github.com"
        ssh-add ~/.ssh/id_ed25519
    fi
    echo ==============================================
    cat ~/.ssh/id_ed25519.pub
    clip ~/.ssh/id_ed25519.pub
    echo == copied to clipboard ==
}

function mkcdir() {
    mkdir -p $1 && cd $1
}

if command -v exa &>/dev/null; then
    alias ls='exa -g --icons --color=always'
    alias ll='ls -alhF --git'
else
    alias ls='ls --color=auto'
    alias ll='ls -alhF'
fi
alias la='ls -Ah'
alias l='ls -Fh'

alias lso='/bin/ls'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if command -v cpg &>/dev/null; then
    alias cp='cpg -g'
fi

if command -v mvg &>/dev/null; then
    alias mv='mvg -g'
fi

if command -v ranger &>/dev/null; then
    alias f=ranger
fi

if command -v go &>/dev/null; then
    export GOPATH="$HOME/.go"
    export PATH=$PATH:$(go env GOPATH)/bin
fi

if command -v todo-cli &>/dev/null; then
    todo-cli check 2>/dev/null
    if [ $? -eq 0 ] && [ -z ${TODO+x} ]; then
        todo-cli print
        export TODO="shown"
    fi
fi
function calc() { python -c "print($@)"; }

function mkcpair() {
    for i in $@; do
        touch $i.c $i.h
        # add include guard
        echo "#ifndef ${i^^}_H" >$i.h
        echo "#define ${i^^}_H" >>$i.h
        echo "" >>$i.h
        echo "#endif // ${i^^}_H" >>$i.h
    done
}

function check-network() {
    echo -n "Password :"
    read -rs PASS
    echo
    echo -n Data Used:
    netz-checker ghibranresearch@gmail.com $PASS
}

function dd-iso() {
    sudo dd bs=4M if=$1 of=$2 conv=fsync oflag=direct status=progress
}

alias gitpush='git push origin $(git branch --show-current)'
alias gitc='git commit -m'
alias gitpull='git pull origin $(git branch --show-current)'

# Emacs aliases
alias emacst='emacsclient -c -t -s term'
alias codet=emacst
alias emacs-server='/usr/bin/emacs'
alias restart-emacs='systemctl reload-or-restart emacs --user ; systemctl status --user emacs'

function file() {
    code -e "(dired \"$1\")"
}

alias dbg-emacs='emacs-server --debug-init --fg-daemon=debug'
alias kill-emacs="emacsclient -e  '(kill-emacs) || killall emacs'"

function code() {

    local e=$(emacsclient -n -e -s server "(> (length (frame-list)) 1)")
    if [ "$e" = "t" ]; then
        emacsclient -n -s server -a "" "$@"
    else
        emacsclient -c -s server -n -a "" "$@"
    fi
}

alias emacs='code'
alias vcode='/usr/bin/code'

# function man() {
#     emacst -s term -e "(man \"$*\")"
# }

[ -f /opt/asdf-vm/asdf.sh ] && source /opt/asdf-vm/asdf.sh

alias yas="yay -Slq | fzf -m --preview 'yay -Si {1}' | xargs -ro  yay -S"
alias yar="yay -Qqe | fzf -m --preview 'yay -Si {1}' | xargs -ro  yay -Rns"
alias yayu="yay -Qu | fzf -m --preview 'yay -Si {1}' | cut -d' ' -f1 | xargs -ro  yay -Syy"
alias sman="apropos . | fzf -m --preview 'man {1}{2}'  --bind ctrl-h:preview-up,ctrl-l:preview-down | awk '{printf(\"%s%s\",\$1,\$2)}' | xargs man"

[ -d $HOME/.bin ] && export PATH=$PATH:$HOME/.bin
[ -d $HOME/.config/emacs/bin ] && export PATH=$PATH:$HOME/.config/emacs/bin
[ -d $HOME/.local/bin ] && PATH=$PATH:$HOME/.local/bin
[ -d /snap/bin ] && PATH=$PATH:/snap/bin

if command -v lvim >/dev/null; then
    alias vim='lvim'
    alias nvim='lvim'
    MANPAGER='lvim +Man!'
fi

if command -v rmtrash >/dev/null; then
    alias rm='rmtrash'
    alias rmdir='rmdirtrash'
    alias sudo='sudo '
fi

function see-docker() {
    docker create --name="tmp_$$" $1
    docker export tmp_$$ | tar tvph
    docker rm tmp_$$
}

alias unadb="adb shell pm list packages  | fzf | awk -F':' '{print \$2}' | xargs -ro adb shell pm uninstall -k --user 0"

# if [ -f /usr/share/doc/find-the-command/ftc.bash ]; then
#     source /usr/share/doc/find-the-command/ftc.bash
# fi

alias make='make --no-print-directory '

if command -v scc &>/dev/null; then
    alias cloc='scc'
fi

if command -v trash-restore &>/dev/null; then
    alias restore='trash-restore'
fi

# alias genmac='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//"'
# generate non-broadcasting mac address
alias genmac='openssl rand -hex 6 | sed "s/\(..\)/\1:/g; s/.$//" | sed "s/ff/fe/"'

if command -v pnpm &>/dev/null; then
    alias npm='pnpm'
    alias npx='pnpx'
fi

# pnpm
export PNPM_HOME="/home/gibi/.local/share/pnpm"
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

alias update-system="yay -Syy archlinux-keyring && yay --sudoloop"

alias nano='nvim'

function genpass() {
    local cmd
    [[ -f '/usr/bin/genpass' ]] && cmd='/usr/bin/genpass' || cmd="$HOME/.bin/genpass"
    local val
    val=$($cmd $@)
    clip "$val"
    echo "$val"
}

if command -v qmv &>/dev/null; then
    alias qmv='qmv -f do '
fi

function addprj() {
    local d=$1
    [ -z "$d" ] && d=$(pwd)
    emacsclient -e "(projectile-add-known-project \"$d\" )" &>/dev/null
}

export PROJECT_DIR="$HOME/Workspace"
function makeproject() {

    if [ $# -eq 0 ]; then
        echo "err: No arguments"
        return 254
    fi

    mkdir -p $PROJECT_DIR/$1
    cd $PROJECT_DIR/$1
    git init .
    cd - &>/dev/null
    addprj "$PROJECT_DIR/$1"
}

shell() {
    CMD="$@"
    while read -p "${CMD}> " -re cmd; do
        case "$cmd" in
            "") continue ;;
            exit) break ;;
            quit) break ;;
            *)
                echo "+ ${CMD} ${cmd}"
                ${CMD} ${cmd}
                ;;
        esac
    done
}
alias pip='pipx'

alias serveweb='python3 -m http.server 8000'

alias telnet='busybox telnet'
alias volumecli='pulsemixer'

function gitignore() {
    local args=${@// /,}
    curl -sL https://www.toptal.com/developers/gitignore/api/$args > .gitignore
}
