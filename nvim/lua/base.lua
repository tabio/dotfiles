vim.cmd("autocmd!")

vim.scriptencoding = "utf-8"

vim.wo.number = true

-- 全角スペースを可視化
vim.api.nvim_create_augroup('extra-whitespace', {})
vim.api.nvim_create_autocmd({'VimEnter', 'WinEnter'}, {
  group = 'extra-whitespace',
  pattern = {'*'},
  command = [[call matchadd('ExtraWhitespace', '[\u200B\u3000]')]]
})
vim.api.nvim_create_autocmd({'ColorScheme'}, {
  group = 'extra-whitespace',
  pattern = {'*'},
  command = [[highlight default ExtraWhitespace ctermbg=202 ctermfg=202 guibg=salmon]]
})

-- obsidianでmdファイル上でチェックボックスの表示を可能にするため
-- 全体に適応するとjsonファイルのダブルクォート表示が崩れる影響が出たのでファイルを限定する
vim.api.nvim_create_augroup('set-conceallevel', {})
vim.api.nvim_create_autocmd({'BufRead','BufNewFile'}, {
  group = 'set-conceallevel',
  pattern = {'*.md'},
  command = [[set conceallevel=2]]
})