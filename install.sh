#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

function github_latest_release()
{
        curl --silent "https://api.github.com/repos/$1/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'
}

function install_cscope()
{
		mkdir tmp
		cd tmp
		curl -O -J -L https://github.com/mellowcandle/cscope/archive/master.zip
		unzip cscope-master.zip
		cd cscope-master
		autoreconf -i
		./configure
		make -j8
		sudo make install
		cd ../..
		rm -rf tmp
}

function install_bat()
{
		batver=$(github_latest_release sharkdp/bat)
		curl -O -J -L https://github.com/sharkdp/bat/releases/download/${batver}/bat_${batver}_amd64.deb
		sudo dpkg -i bat_${batver}_amd64.deb
}

########## Variables
#echo $batver

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old      # old dotfiles backup directory
files=".tmux.conf .bashrc .bash_aliases .bash_arch .gitignore .gitconfig .gitconfig_gmail .gitconfig_intel .vimrc .vim .git-prompt .acd_func .pwclientrc"    # list of files/folders to symlink in homedir


# Detect the current distrubution we're in:
arch=$(uname -m)
kernel=$(uname -r)
if [ -n "$(command -v lsb_release)" ]; then
	distroname=$(lsb_release -s -d)
elif [ -f "/etc/os-release" ]; then
	distroname=$(grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//g' | tr -d '="')
elif [ -f "/etc/debian_version" ]; then
	distroname="Debian $(cat /etc/debian_version)"
elif [ -f "/etc/redhat-release" ]; then
	distroname=$(cat /etc/redhat-release)
else
	distroname="$(uname -s) $(uname -r)"
fi

echo "Running on: $distroname"

mkdir -p ~/bin
mkdir -p ~/.vim_runtime/temp_dirs/undodir
##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
    echo "Moving any existing dotfiles from ~ to $olddir"
    mv ~/$file $olddir 
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done

# Build and install cscope (my version becuase upstream is shit) */

# .gdbinit is in a special directory
ln -s -f $dir/extra/gdb-dashboard/.gdbinit ~/.gdbinit
# Install filepicker
ln -s -f $dir/extra/PathPicker/fpp ~/bin/fpp
ln -s -f $dir/extra/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy

ln -s -f $dir/extra/tmux-vim-select-pane /bin/tmux-vim-select-pane
ln -s -f $dir/extra/pastebin.py /bin/pastebin
ln -s -f $dir/extra/.tmux/.tmux.conf ~/.tmux.conf
cp $dir/extra/.tmux/.tmux.conf.local ~/

sudo ln -s -f $dir/extra/android-completion/android /etc/etc/bash_completion.d/android
sudo ln -s -f $dir/extra/bitbake-bash-completion/bitbake /etc/etc/bash_completion.d/bitbake
sudo ln -s $dir/extra/tmux-bash-completion/completions/tmux /etc/bash_completions.d/tmux

echo "source $dir/gitstatus/gitstatus.prompt.sh" >> ~/.bashrc

# Install pwclint
curl -o ~/bin/pwclient -J -L http://patchwork.ozlabs.org/pwclient/
chmod +x ~/bin/pwclient

# Install TLDR
curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
chmod +x ~/bin/tldr

install_bat
install_cscope

