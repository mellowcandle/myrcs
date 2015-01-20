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
set autoindent
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
