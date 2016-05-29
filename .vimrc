set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tpope/vim-fugitive'
Plugin 'hrp/EnhancedCommentify'
Plugin 'vim-scripts/ZoomWin'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'vim-scripts/cscope.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ervandew/supertab'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/syntastic'
Plugin 'vim-scripts/taglist.vim'
"Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
Plugin 'vim-airline/vim-airline'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-session'
Plugin 'Valloric/YouCompleteMe'
Plugin 'airblade/vim-gitgutter'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set nocp
syntax on
filetype plugin indent on
colorscheme monokai
set wildmenu
set showcmd
syn on se title
set tabstop=4
set softtabstop=4
set shiftwidth=4
set noexpandtab
set hlsearch
set smarttab
"set incsearch

set ignorecase
set smartcase
set backspace=indent,eol,start
"set autoindent
set nostartofline
set ruler
set laststatus=2
set showmatch
set matchtime=5

" if has('mouse')
" 	set mouse=a " all mode
" 	set mousehide " hide mouse when typing
" endif
set cmdheight=2
set nu
"set textwidth=80


" My mappings
map <C-n> :NERDTreeToggle<CR>
" Back and forward in tags
map <M-Left> <C-T>
map <M-Right> <C-]>
nnoremap <silent> <F6> :ToggleBufExplorer<CR>
map <F8> :TlistToggle<CR>
map <F9> :Hexmode<CR>
noremap <leader>st :SyntasticToggleMode<CR>
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode
"
" Automatic tag loading
set tags=./tags;/

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
let g:Tlist_WinWidth=50

" -----------------------------------------
"  Snippets mapping
" -----------------------------------------
"let g:UltiSnipsExpandTrigger="<tab>"
"let g:UltiSnipsJumpForwardTrigger="<c-j>"
"let g:UltiSnipsJumpBackwardTrigger="<c-b>"

" ------------------
" YCM Configuration
" ------------------
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 1
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
"let g:ycm_key_list_select_completion = ["<C-TAB>","<Down>"]
"let g:ycm_key_list_previous_completion = ["<C-S-TAB>", "<Up>"]
let g:SuperTabDefaultCompletionType = "<C-Tab>"

" NOTE: VisualComment,Comment,DeComment are plugin mapping(start with <Plug>),
" so can't use remap here
vmap <unique> <F10> <Plug>VisualComment
nmap <unique> <F10> <Plug>Comment
imap <unique> <F10> <ESC><Plug>Comment
vmap <unique> <C-F10> <Plug>VisualDeComment
nmap <unique> <C-F10> <Plug>DeComment
imap <unique> <C-F10> <ESC><Plug>DeComment


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'
" Hex file adding functionality 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    silent :e " this will reload the file without trickeries 
              "(DOS line endings will be shown entirely )
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

"------------------
" Syntactic stuff
" -----------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:statline_syntastic = 0
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = { 'mode': 'passive' }
"--------------------------
" Remove trailing whitespace
" --------------------------
function RemoveTrailingWhitespace()
let b:curcol = col(".")
let b:curline = line(".")
silent! %s/\s\+$//
silent! %s/\(\s*\n\)\+\%$//
call cursor(b:curline, b:curcol)
endfunction

"-----------------------
" NerdTree customization
" ----------------------
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
let NERDTreeIgnore=['.*\.o$']
let NERDTreeIgnore+=['.*\.d$']
let NERDTreeIgnore+=['.*\~$']
let NERDTreeIgnore+=['.*\.out$']
let NERDTreeIgnore+=['.*\.so$', '.*\.a$']
" Quit with :Q
command -nargs=0 Quit :qa!


" Session plugin
let g:session_autosave='yes'
let g:session_autoload='yes'

"-----------------------
" Airline customization
" ----------------------
let g:airline_powerline_fonts = 1

"-----------------------
" Ctrl-p customization
" ----------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" Python stuff
nnoremap <silent> <F5> :!clear;python %<CR>

