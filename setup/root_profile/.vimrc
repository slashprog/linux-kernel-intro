set nobackup
set nu

filetype plugin on 
set shiftwidth=4
set tabstop=4
set textwidth=79
set autoindent
set ruler
set mouse=a
set ttymouse=xterm2

autocmd BufRead,BufNewFile *.py syntax on
autocmd BufRead,BufNewFile *.py set ai
autocmd BufRead *.py set smartindent

autocmd BufRead,BufNewFile *.c set cindent
autocmd BufRead,BufNewfile *.c set comments=sl:/*,mb:*,elx:*/

syntax on

cs add /usr/local/build/linux/cscope.out
