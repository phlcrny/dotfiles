set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

call plug#begin()

Plug 'nvim-lua/plenary.nvim', { 'tag': '*' }
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'folke/zen-mode.nvim', { 'tag': '*' }
Plug 'itspriddle/vim-shellcheck', { 'tag': '*' }
Plug 'psf/black', { 'tag': '*' }
Plug 'vim-scripts/indentpython.vim', { 'tag': '*' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

nnoremap <leader>FF <cmd>Telescope find_files<cr>
nnoremap <leader>Fg <cmd>Telescope live_grep<cr>
nnoremap <leader>Fb <cmd>Telescope buffers<cr>
nnoremap <leader>Fh <cmd>Telescope help_tags<cr>
