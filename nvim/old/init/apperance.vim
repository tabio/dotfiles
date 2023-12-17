"==========
" 表示
"==========

set showmatch                                     " 括弧入力時に対応する括弧を表示
set number                                        " 行数表示
set list                                          " 不可視文字表示
set listchars=tab:>.,trail:_,extends:>,precedes:< " 不可視文字の表示形式
set display=uhex                                  " 印字不可能文字を16進数で表示
" set cursorline                                    " カーソル行をハイライト
set ttyfast                                       " 高速ターミナル接続を行う

" 全角スペース表示
highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
match ZenkakuSpace /　/
