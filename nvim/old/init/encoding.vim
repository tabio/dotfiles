set ffs=unix,dos,mac  " 改行文字
set encoding=utf-8    " デフォルトエンコーディング

" 文字コード認識はbanyan/recognize_charcode.vimへ

" 以下のファイルの時は文字コードをutf-8に設定
autocmd FileType svn :set fileencoding=utf-8
autocmd FileType js :set fileencoding=utf-8
autocmd FileType css :set fileencoding=utf-8
autocmd FileType html :set fileencoding=utf-8
autocmd FileType xml :set fileencoding=utf-8
autocmd FileType java :set fileencoding=utf-8
autocmd FileType scala :set fileencoding=utf-8
