autoload -Uz compinit
compinit

eval "$(sheldon source)"

export LANG=ja_JP.UTF-8
export EDITOR='nvim'

# alias
alias cat="bat"
alias diff="delta"
alias ee="eza -aahl --icons --git"
alias ei="eza --icons --git"
alias et="eza -T -L 3 -a -I 'node_modules|.git|.cache' --icons"
alias ls=ei
alias ll=ee
alias lt=et
alias vi="nvim"

autoload -Uz colors
colors

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# ビープ音の停止
setopt no_beep

# ビープ音の停止(補完時)
setopt nolistbeep

# cd -<tab>で以前移動したディレクトリを表示
setopt auto_pushd

# ヒストリ(履歴)を保存、数を増やす
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# zshの間でヒストリを共有する
setopt share_history
setopt inc_append_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# fzfを利用して履歴検索
# fzf history
function fzf-select-history() {
    BUFFER=$(history -n -r 1 | fzf --query "$LBUFFER" --reverse)
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-select-history

# cdr自体の設定
autoload -Uz cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
fi

# fzf cdr
function fzf-cdr() {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | fzf --reverse)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N fzf-cdr

# キーバインディングをemacs風に(-vはvim)
bindkey -v

# キーバーインド変更
# bindkey -vの影響を考慮して以下に設定する
bindkey '^j' vi-cmd-mode
bindkey '^r' fzf-select-history
bindkey '^e' fzf-cdr

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

# starship
eval "$(starship init zsh)"
