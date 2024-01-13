export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git brew zsh-completions zsh-autosuggestions git-open)
source $ZSH/oh-my-zsh.sh
export LANG=ja_JP.UTF-8
export EDITOR='nvim'

# alias
alias gg="git grep -n"
alias ll="ls -lha"
alias vi="nvim"

# 色を使用
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

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 直前と同じコマンドの場合は履歴に追加しない
setopt hist_ignore_dups

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# キーバインディングをemacs風に(-vはvim)
bindkey -v

# 補完を強化
plugins=(… zsh-completions)
autoload -U compinit && compinit

# fzf + ag
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

_has() {
  return $( whence $1 &>/dev/null )
}

if _has fzf && _has ag; then
  export FZF_DEFAULT_COMMAND='ag -g ""' # 検索にagを利用することでgitignoreで指定しているファイルを対象外に
  export FZF_DEFAULT_OPTS='--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108 --color info:108,prompt:109,spinner:108,pointer:168,marker:168'
fi

# starship
eval "$(starship init zsh)"

# asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

###### キーバーインド変更
bindkey '^j' vi-cmd-mode
