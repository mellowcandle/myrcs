filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" YCM is only worth loading where there is a .ycm_extra_conf.py to drive it, so
" disable it everywhere else. g:loaded_youcompleteme is YCM's own skip-load
" guard, which means the test has to be empty(db): setting it on !empty(db)
" turned YCM off in precisely the trees it was wanted in.
let db = findfile(".ycm_extra_conf.py", ".;")
if empty(db)
let g:loaded_youcompleteme = 1
endif

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-scripts/ZoomWin'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'steffanc/cscopemaps.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/fzf.vim'
Plugin 'tpope/vim-surround'
"Plugin 'scrooloose/syntastic'
"Plugin 'SirVer/ultisnips'
"Plugin 'honza/vim-snippets'
Plugin 'vim-airline/vim-airline'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'airblade/vim-gitgutter'
Plugin 'Chiel92/vim-autoformat'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'kshenoy/vim-signature'
Plugin 'wikitopian/hardmode'
Plugin 'majutsushi/tagbar'
Plugin 'vivien/vim-linux-coding-style'
Plugin 'embear/vim-localvimrc'
Plugin 'tpope/vim-vinegar.git'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-dispatch'
Plugin 'airblade/vim-rooter'
Plugin 'vim-scripts/VisIncr'
Plugin 'vim-scripts/YankRing.vim'
" tabnine-vim is a fork of YouCompleteMe, so loading both means two copies of
" the same plugin fighting over the same mappings and python layer. YCM is the
" one this configuration actually sets up, so keep it and drop the fork.
"
" Note that YCM's master branch has required Python >= 3.12 since ab6a321d
" (2025-12-29), and vim on Amazon Linux 2023 is +python3/dyn-stable against
" libpython3.9, so install.py refuses to run and ycm_core is never built. YCM
" then loads and disables itself, quietly: no completion, but no error either.
" The last revision that accepts Python 3.6 is dfe24dae, and building it needs
" python3-devel.
Plugin 'Valloric/YouCompleteMe'
"
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
