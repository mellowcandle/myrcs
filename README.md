# To install first run

apt-get install cmake python-dev htop iotop tcputils

Download clang:
http://llvm.org/releases/3.5.1/clang+llvm-3.5.1-x86_64-linux-gnu.tar.xz

git submodule update --init --recursive

cd ~
mkdir ycm_build
cd ycm_build
cmake -G "Unix Makefiles" -DPATH_TO_LLVM_ROOT=~/ycm_temp/llvm_root_dir . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
make ycm_support_libs

Once in a while you would probably want to update the dependencies like that:\
git submodule foreach git pull --rebase origin master
