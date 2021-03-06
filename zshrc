# zsh の設定を管理するフレームワーク
#export ZSH=/Users/{user_name}/.oh-my-zsh
export ZSH=/home/{user_name}/.oh-my-zsh

# theme
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# 補完時に大文字と小文字を区別して補完したい場合は有効化
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# 自動アップデートの無効化
DISABLE_AUTO_UPDATE="true"

# 自動アップデートの更新間隔
# export UPDATE_ZSH_DAYS=13

# lsコマンド実行時に色分けしたくない場合は有効化
# DISABLE_LS_COLORS="true"

# ターミナルのタイトル表示を変えたくない場合は有効化
# DISABLE_AUTO_TITLE="true"

# コマンドを間違えたときに訂正する機能を使いたい場合は有効化
# ENABLE_CORRECTION="true"

# コマンドの補完待ち時に赤色のドット（......）を表示したい場合は有効化
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# historyコマンドで実行日時情報を表示したい場合は有効化
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# ロードしたいプラグイン
plugins=(git ruby bundler brew rails zsh-completions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export LANG=ja_JP.UTF-8

export EDITOR='vim'

# コンパイルフラグ。Macでコンパイルしてインストールするときに必要になる場合がある
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# aliasを上書きするファイル
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias gg="git grep -n"
alias ll="ls -lha"
alias vi="vim"

# 色を使用
autoload -Uz colors
colors

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# cdなしでディレクトリ移動
setopt auto_cd

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
if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi
autoload -U compinit && compinit

# /etc/profile.d/rbenv.sh とかなかったら
eval "$(rbenv init -)"

###### キーバーインド変更
# 履歴検索pecoの利用
function peco-select-history() {
  local tac
  if which tac > /dev/null; then
    tac="tac"
  else
    tac="tail -r"
  fi
  BUFFER=$(\history -n 1 | \
    eval $tac | \
    peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# ctrl+j でノーマルモードに
bindkey '^j' vi-cmd-mode
