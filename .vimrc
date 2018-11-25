
set nocompatible              " be iMproved, required

if filereadable(expand("~/.vim/plugins.vim"))
  source ~/.vim/plugins.vim
endif

" If there are any machine-specific tweaks for Vim, load them from the following file.
if filereadable(expand("~/.vimrc_local"))
  source ~/.vimrc_local
endif

set term=screen-256color

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nowrap
set hidden
set nocp
syntax on
filetype plugin indent on
colorscheme monokai
set wildmenu
set showcmd
syn on se title
set tabstop=4
set softtabstop=8
set shiftwidth=8
set noexpandtab
set hlsearch
set smarttab
set ignorecase
set smartcase
set backspace=indent,eol,start
set nostartofline
set ruler
set laststatus=2
set showmatch
set matchtime=5
set cmdheight=2
set nu
set clipboard=unnamedplus
set wildignore=*.so,*.swp,*.zip,*.d,*.o,*.dtb
set nobackup
set nowb
set noswapfile
set showmode

" command :W sudo saves the file
" (useful for handling the permission-denied error)
command! W w !sudo tee % > /dev/null
"
" Quit with :Q
command! -nargs=0 Quit :qa!

" Watch this file
augroup myvimrc
  au!
  au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END
"
au BufRead,BufNewFile *.s set filetype=nasm

" My mappings
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <silent> <leader>l :LinuxCodingStyle<cr>
map <C-n> :NERDTreeToggle<CR>
" Back and forward in tags
map <M-Left> <C-T>
map <M-Right> <C-]>

nnoremap <F2> :set invpaste paste?<CR>
nnoremap <F3> :CtrlPMRUFiles<CR> 
nnoremap <silent> <F6> :ToggleBufExplorer<CR>
nmap	 <F7> :TagbarToggle<CR>
nnoremap <F8> :call ToggleSyntastic()<CR>

set pastetoggle=<F2>

" Automatic tag loading
set tags=./tags;

function! LoadCscope()
  let db = findfile("cscope.out", ".;")
	if (!empty(db))
		let path = strpart(db, 0, match(db, "/cscope.out$"))
		set nocscopeverbose " suppress 'duplicate connection' error
		exe "cs add " . db . " " . path
		set cscopeverbose
	endif
  endfunction

au BufEnter /* call LoadCscope()


function! ToggleSyntastic()
    for i in range(1, winnr('$'))
        let bnum = winbufnr(i)
        if getbufvar(bnum, '&buftype') == 'quickfix'
            lclose
            return
        endif
    endfor
    SyntasticCheck
endfunction

"
" -------------------------------------
" Local vimrc settings
" -------------------------------------
let g:localvimrc_sandbox = 0
let g:localvimrc_ask = 0

" -------------------------------------
" .h file should be treated as c files.
" -------------------------------------
let g:c_syntax_for_h = 1

" ----------------------------------------
" Enhanced commentify binding and settings
" ----------------------------------------
let g:EnhCommentifyFirstLineMode='yes'
let g:EnhCommentifyRespectIndent='yes'
let g:EnhCommentifyUseBlockIndent='yes'
let g:EnhCommentifyAlignRight = 'yes'
let g:EnhCommentifyPretty = 'yes'
let g:EnhCommentifyBindInNormal = 'no'
let g:EnhCommentifyBindInVisual = 'no'
let g:EnhCommentifyBindInInsert = 'no'

" -----------------------------------------
"  Default size for NerdTree and Taglist
" -----------------------------------------
let g:NERDTreeWinSize=50
let g:NERDTreeHijackNetrw=0
"let g:Tlist_WinWidth=50

" -----------------------------------------
"  Snippets mapping
" -----------------------------------------
let g:UltiSnipsExpandTrigger="<c-j>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsSnippetsDir="~/myrcs/private_snippets"

" ------------------
" YCM Configuration
" ------------------
" Provide a way to insert tab without completion, phew...
inoremap <Leader><Tab> <Tab>

let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_filetype_blacklist = {
	\ 'tagbar' : 1,
	\ 'qf' : 1,
	\ 'notes' : 1,
	\ 'markdown' : 1,
	\ 'unite' : 1,
	\ 'text' : 1,
	\ 'vimwiki' : 1,
	\ 'pandoc' : 1,
	\ 'tree' : 1,
	\ 'mail' : 1
	\}
" -------------------------------------------
" Make YCM and Ultisnips work together nicely
" -------------------------------------------
"let g:ycm_key_list_select_completion=[]
"let g:ycm_key_list_previous_completion=[]
"let g:ycm_key_list_select_completion = ["<C-TAB>", "<Down>"]
"let g:ycm_key_list_previous_completion = ["<C-S-TAB>", "<Up>"]

" NOTE: VisualComment,Comment,DeComment are plugin mapping(start with <Plug>),
" so can't use remap here
vmap <silent> <F10> <Plug>VisualComment
nmap <silent> <F10> <Plug>Comment
imap <silent> <F10> <ESC><Plug>Comment
vmap <silent> <C-F10> <Plug>VisualDeComment
nmap <silent> <C-F10> <Plug>DeComment
imap <silent> <C-F10> <ESC><Plug>DeComment

"------------------
" Syntactic stuff
" -----------------
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_mode_map = { 'mode': 'passive' }

let g:syntastic_aggregate_errors = 1
let g:syntastic_c_checkers = ['checkpatch']
let g:syntastic_c_checkpatch_args = "--strict"
"let g:syntastic_cpp_checkers = ['gcc' ]

"--------------------------
" Remove trailing whitespace
" --------------------------
function! RemoveTrailingWhitespace()
let b:curcol = col(".")
let b:curline = line(".")
silent! %s/\s\+$//
silent! %s/\(\s*\n\)\+\%$//
call cursor(b:curline, b:curcol)
endfunction

"-----------------------
" NerdTree customization
" ----------------------
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

let NERDTreeIgnore=['.*\.o$']
let NERDTreeIgnore+=['.*\.d$']
let NERDTreeIgnore+=['.*\~$']
let NERDTreeIgnore+=['.*\.out$']
let NERDTreeIgnore+=['.*\.so$', '.*\.a$']
"

" Session plugin
let g:session_autosave='yes'
let g:session_autoload='yes'
let g:session_autosave_periodic = 1
let g:session_autosave_silent = 1

"-----------------------
" Airline customization
" ----------------------
let g:airline_powerline_fonts = 1
let g:airline#extensions#syntastic#enabled = 1
let airline#extensions#syntastic#error_symbol = 'E:'
let airline#extensions#syntastic#stl_format_err = '%E{[%e(#%fe)]}'
let airline#extensions#syntastic#warning_symbol = 'W:'
let airline#extensions#syntastic#stl_format_warn = '%W{[%w(#%fw)]}'
"-----------------------
" Ctrl-p customization
" ----------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_max_files = 100000

"-----------------------
" ack.vim customization
" ----------------------

" Use AG if available
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Don't jump to first result automatically  
cnoreabbrev Ack Ack!
noremap <Leader>a :Ack!<cr>
let g:ack_use_dispatch = 1
"-----------------------
" auto-format customization
" ----------------------

" Enable debugging
" let g:autoformat_verbosemode=1


" noremap <F3> :let g:formatters_c = ['my_c_kernelspace'] | Autoformat<CR>

" Disallow vim's automatic formatting incase astyle is missing
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

" Specific formatting options
let g:formatdef_my_c_userspace = '"astyle --mode=cs --style=ansi -pcHs4"'
let g:formatdef_my_c_kernelspace = '"astyle --mode=c --style=knf --indent=tab --align-pointer=name"'

" let g:formatters_c = ['my_c_kernelspace']

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Persistent undo
try
    set undodir=~/.vim_runtime/temp_dirs/undodir
    set undofile
catch
endtry
