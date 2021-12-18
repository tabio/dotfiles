" ENV
let $CACHE = empty($XDG_CACHE_HOME) ? expand('$HOME/.cache') : $XDG_CACHE_HOME
let $CONFIG = empty($XDG_CONFIG_HOME) ? expand('$HOME/.config') : $XDG_CONFIG_HOME

" dein settings {{{
if &compatible
  set nocompatible
endif

augroup MyAutoCmd
  autocmd!
  autocmd QuickFixCmdPost *grep* cwindow
  autocmd BufNewFile,BufRead *.py setlocal tabstop=4 softtabstop=4 shiftwidth=4
augroup END

" dein.vimのディレクトリ
let s:dein_dir = expand('$CACHE/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vimがなければgit clone
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
end

" 設定開始
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " プラグイン
  let s:toml_dir  = expand('$CONFIG/nvim/toml/')
  call dein#load_toml(s:toml_dir . 'base.toml',               {'lazy': 0})
  call dein#load_toml(s:toml_dir . 'search_moving.toml',      {'lazy': 0})
  call dein#load_toml(s:toml_dir . 'appearance.toml',         {'lazy': 0})
  call dein#load_toml(s:toml_dir . 'edit.toml',               {'lazy': 0})
  call dein#load_toml(s:toml_dir . 'dein_lazy.toml',          {'lazy': 1})
  call dein#load_toml(s:toml_dir . 'syntax_lazy.toml',        {'lazy': 1})
  call dein#load_toml(s:toml_dir . 'utility_lazy.toml',       {'lazy': 1})
  call dein#load_toml(s:toml_dir . 'auto_complete_lazy.toml', {'lazy': 1})

  " 設定終了
  call dein#end()
  call dein#save_state()
endif

" その他未インストールのものがあったらインストール
if dein#check_install()
  call dein#install()
endif
" }}}

runtime! init/*.vim
