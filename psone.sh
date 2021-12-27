_ps1_git_branch_legacy() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

_ps1_git_branch() {
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    local bg_green="\[$(tput setab 28)\]"
    local fg_green="\[$(tput setaf 28)\]"
    local bg_dark_gray="\[$(tput setab 235)\]"
    local fg_blue="\[$(tput setaf 19)\]"
    local reset="\[$(tput sgr0)\]"
    local git_symbol=''

    if [[ ! -z "$branch" ]]; then
        echo -n "${fg_blue}${bg_green}${reset}${bg_green}${git_symbol}${branch}${reset}${bg_dark_gray}${fg_green}${reset}"
    else
        echo -n "${fg_blue}${reset}"
    fi
}

__ws_short_path() {
    local filepath="$1"
    local pwd_path=$filepath
    local homelen=${#HOME}

    if [[ $HOME = ${pwd_path:0:$homelen} ]]; then
        local pathlen=${#pwd_path}
        local path="~${pwd_path:$homelen:$pathlen}"
    else
        local path=$filepath
    fi

    local path_parts=$(echo $path | tr "/" "\n" | sed \$d)
    local base_path=$(basename -- $path)

    for path_item in $path_parts; do
        if [[ "${path_item:0:1}" = "." ]]; then
            echo -n "${path_item:0:2}/"
        else
            echo -n "${path_item:0:1}/"
        fi
    done

    echo -n $base_path
} 

_ps1_cwd() {
    local _pwd="$(pwd)"
    local retval=$(__ws_short_path $_pwd)

    echo -n $retval
} 

_ps1_kube() {
    local context_name=$(kubectl config current-context 2> /dev/null)

    if [[ -n $context_name ]]; then
        local cluster=$(kubectl config get-contexts $context_name --no-headers | awk '{ print $3 }')
        local namespace=$(kubectl config get-contexts $context_name --no-headers | awk '{ print $5 }')

        echo -n "$context_name:$cluster:$namespace"
    else
        echo -n "" 
    fi
} 

_ps1_left() {
    local bg_orange="\[$(tput setab 166)\]"
    local fg_orange="\[$(tput setaf 166)\]"
    local bg_green="\[$(tput setab 28)\]"
    local fg_green="\[$(tput setaf 28)\]"
    local bg_blue="\[$(tput setab 19)\]"
    local fg_blue="\[$(tput setaf 19)\]"
    local bg_purple="\[$(tput setab 54)\]"
    local fg_purple="\[$(tput setaf 54)\]"
    local bg_gray="\[$(tput setab 241)\]"
    local fg_gray="\[$(tput setaf 241)\]"
    local reset="\[$(tput sgr0)\]"
    local kube_symbol=$'\u2388'
    local bg_kube_blue="\[$(tput setab 26)\]"
    local fg_kube_blue="\[$(tput setaf 26)\]"
    local folder_symbol=$'\U0001f4C1'
    local kube_info=$(_ps1_kube)
    local retval="${bg_gray}\T${reset}${fg_gray}${bg_purple}${reset}${bg_purple}\u@\h${fg_purple}"

    if [[ -n $kube_info ]]; then
        local retval="${retval}${bg_kube_blue}${reset}${bg_kube_blue}${kube_symbol}$(_ps1_kube)${bg_blue}${fg_kube_blue}"
    fi


    echo -n "${retval}${bg_blue}${reset}${bg_blue}${folder_symbol}$(_ps1_cwd)${reset}$(_ps1_git_branch)"
} 

_ps1_right() {
    # couldn't figure out a way to set this without using a fixed length text so it's empty
    echo -n ""
} 

# Lots of great customization examples: https://gist.github.com/justintv/168835
_ps1_init() {
    local bg_dark_gray="\[$(tput setab 235)\]"
    local reset="\[$(tput sgr0)\]"

    # write gray whitespace on the entire line then carriage return \r to the beginning and overwrite
    export PS1=$(printf "${bg_dark_gray}%*s${reset}\r%s\n\$ " "$(tput cols)" "$(_ps1_right)" "$(_ps1_left)") 
}

export PROMPT_COMMAND=_ps1_init
