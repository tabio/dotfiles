set autoread                   " 他で書き換えられたら自動で読み直す
set backspace=start,eol,indent " 挿入モードでbackspaceで行末の改行やタブを削除できるようにする
set matchtime=2                " 対応する括弧の表示時間を2にする
set mouse=                     " マウスとの連動機能のOFF
set noswapfile                 " swapを作らない
set nowrap                     " 折り返し設定
set vb t_vb=                   " ビープをならさない
set whichwrap=b,s,[,],<,>,~    " backspace,space,各矢印キー,チルダキーを使用できるようにする
set termguicolors

let mapleader = "\<Space>"

" タブをスペース2個に置換
set expandtab
set ts=2

" 自動インデント インデント時に挿入されるspaceの数
set autoindent
set shiftwidth=2

"========================== クリップボード ==========================
set clipboard=unnamedplus

" 不要にヤンクさせない
nnoremap x "_x
nnoremap s "_s
nnoremap cw "_cw

"========================== キー割り当て ============================
" キー割り当て: ESCをCtrl+j
inoremap <silent> <C-j> <ESC>
vnoremap <silent> <C-j> <ESC>

" ハイライトのoff
nnoremap <C-j> :noh<CR>

nnoremap <Leader>h ^
vnoremap <Leader>h ^
nnoremap <Leader>l $
vnoremap <Leader>l $
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" キー割り当て: ノーマル,ヴィジュアルモードのタブキー
nmap <silent> <Tab> 15<Right>
vmap <silent> <Tab> 15<Right>

" キー割り当て: buffer間移動
nmap <silent> <C-n>      :update<CR>:bn<CR>
imap <silent> <C-n> <ESC>:update<CR>:bn<CR>
vmap <silent> <C-n> <ESC>:update<CR>:bn<CR>
cmap <silent> <C-n> <ESC>:update<CR>:bn<CR>
nmap <silent> <C-p>      :update<CR>:bp<CR>
imap <silent> <C-p> <ESC>:update<CR>:bp<CR>
vmap <silent> <C-p> <ESC>:update<CR>:bp<CR>
cmap <silent> <C-p> <ESC>:update<CR>:bp<CR>

"====================== slim =========================================
autocmd BufRead,BufNewFile *.slim setfiletype slim

"====================== CoffeeScript =================================
au BufRead,BufNewFile,BufReadPre *.coffee    set filetype=coffee
autocmd FileType coffee    setlocal sw=2 sts=2 ts=2 et
"au BufWritePost *.coffee silent CoffeeMake! -b | cwindow | redraw!
nnoremap <silent> <C-C> :CoffeeCompile vert <CR><C-w>h

"====================== Markdown形式のファイル =======================
au BufRead,BufNewFile *.md set filetype=markdown

"====================== jbuilder pryrcをrubyに紐付け =================
au BufRead,BufNewFile *.jbuilder set filetype=ruby
au BufRead,BufNewFile .pryrc     set filetype=ruby

" ファイルタイプ判定をon
filetype plugin on
