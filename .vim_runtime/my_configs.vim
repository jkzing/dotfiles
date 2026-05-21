syntax on
" on pressing tab, insert 2 spaces
set expandtab
" show existing tab with 2 spaces width
set tabstop=2
set softtabstop=2
" when indenting with '>', use 2 spaces width
set shiftwidth=2
" set true colors (24bit)
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif
" set colorscheme
set background=dark
colorscheme onehalfdark
highlight Comment term=NONE cterm=NONE gui=NONE ctermfg=241 guifg=#5c6370
