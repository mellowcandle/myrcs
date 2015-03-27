#!/bin/bash +x 

set -e

curpwd=${PWD}

DOWNLOAD_CLANG=


while getopts ":d" opt; do
  case $opt in
	d)	DOWNLOAD_CLANG=1
            ;;
  esac
done

if [ "$DOWNLOAD_CLANG" = "1" ]; then
	mkdir extra
	cd extra
	wget http://llvm.org/releases/3.5.1/clang+llvm-3.5.1-x86_64-linux-gnu.tar.xz
	tar xf ./clang+llvm-3.5.1-x86_64-linux-gnu.tar.xz
fi

rm -rf ycm_build

mkdir ycm_build
cd ycm_build
cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=$curpwd/extra/clang+llvm-3.5.1-x86_64-linux-gnu . $HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
make ycm_support_libs -j4

cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer
