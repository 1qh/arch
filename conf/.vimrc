call plug#begin('~/.vim/plugged')
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'junegunn/fzf.vim'
Plug 'lambdalisue/fern.vim'
Plug 'sheerun/vim-polyglot'
Plug 'cohama/lexima.vim'
Plug 'sickill/vim-monokai'
call plug#end()

nnoremap <C-A> ggVG

nnoremap <c-s> :w<CR> 
inoremap <c-s> <Esc>:w<CR>a
vnoremap <c-s> <Esc>:w<CR>

nnoremap <c-w> :bd<CR> 
inoremap <c-w> <Esc>:bd<CR>
vnoremap <c-w> <Esc>:bd<CR>

nnoremap <c-p> :Files %:p:h<CR>
inoremap <c-p> <Esc>:Files %:p:h<CR>
vnoremap <c-p> <Esc>:Files %:p:h<CR>

nnoremap <c-b> :Fern %:h -drawer -toggle<CR>
inoremap <c-b> <Esc>:Fern %:h -drawer -toggle<CR>
vnoremap <c-b> <Esc>:Fern %:h -drawer -toggle<CR>

let g:fzf_layout = { 'window': { 'width': 1, 'height': 1 } }
let g:fern#default_hidden=1
" colorscheme monokai
highlight Normal ctermbg=None
set number
set relativenumber
set linebreak

if empty($WAYLAND_DISPLAY)
    finish
endif

function! s:WaylandYank()
    silent call system('wl-copy', getreg(v:event['regname']))
endfunction

augroup waylandyank
    autocmd!
    autocmd TextYankPost * call s:WaylandYank()
augroup END

let prepaste = "silent let @\"=substitute(system('wl-paste --no-newline'), \"\\r\", '', 'g')"

for p in ['p', 'P']
    execute "nnoremap <silent> \"+" . p . " :<C-U>" . prepaste . " \\| exec 'normal! ' . v:count1 . '" . p . "'<CR>"
endfor

for cr in ['<C-R>', '<C-R><C-R>', '<C-R><C-O>', '<C-R><C-P>']
    execute "inoremap <silent> " . cr . "+ <C-O>:<C-U>" . prepaste . "<CR>" . cr . "\""
endfor

