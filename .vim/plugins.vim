filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Load YCM only if found the config file
let db = findfile(".ycm_extra_conf.py", ".;")
if (!empty(db))
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
Plugin 'xolox/vim-misc'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'xolox/vim-session'
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
Plugin 'zxqfl/tabnine-vim'
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
