execute pathogen#infect()
syntax on
filetype plugin indent on

set wildmenu
set showcmd
syn on se title
set tabstop=8
set softtabstop=8
set shiftwidth=8
set noexpandtab
set hlsearch
" #set incsearch

set ignorecase
set smartcase
set backspace=indent,eol,start
"set autoindent
set nostartofline
set ruler
set laststatus=2
"set mouse=a
set cmdheight=2
set nu
set textwidth=80


" My mappings
map <C-n> :NERDTreeToggle<CR>
" Back and forward in tags
map <M-Left> <C-T>
map <M-Right> <C-]>
map <F8> :TlistToggle<CR>
map <C-h> :Hexmode<CR>

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode
"
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
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-b>"

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



