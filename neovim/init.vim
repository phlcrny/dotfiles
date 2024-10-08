set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

call plug#begin()

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'folke/zen-mode.nvim'
Plug 'itspriddle/vim-shellcheck'
Plug 'psf/black'
Plug 'vim-scripts/indentpython.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

call plug#end()

nnoremap <leader>FF <cmd>Telescope find_files<cr>
nnoremap <leader>Fg <cmd>Telescope live_grep<cr>
nnoremap <leader>Fb <cmd>Telescope buffers<cr>
nnoremap <leader>Fh <cmd>Telescope help_tags<cr>
