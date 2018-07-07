#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
files=".tmux.conf .bashrc .bash_aliases .bash_arch .gitignore .gitconfig .gitconfig_gmail .gitconfig_intel .vimrc .vim .git-prompt .acd_func .pwclientrc"    # list of files/folders to symlink in homedir


mkdir -p ~/bin
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


# .gdbinit is in a special directory
ln -s -f $dir/extra/gdb-dashboard/.gdbinit ~/.gdbinit
# Install filepicker
ln -s -f $dir/extra/PathPicker/fpp ~/bin/fpp

ln -s -f $dir/extra/tmux-vim-select-pane /bin/tmux-vim-select-pane
ln -s -f $dir/extra/pastebin.py /bin/pastebin
ln -s -f $dir/extra/android-completion/android /etc/etc/bash_completion.d/android
ln -s -f $dir/extra/bitbake-bash-completion/bitbake /etc/etc/bash_completion.d/bitbake
ln -s -f $dir/extra/.tmux/.tmux.conf ~/.tmux.conf
cp $dir/extra/.tmux/.tmux.conf.local ~/

ln -s $dir/extra/tmux-bash-completion/completions/tmux /etc/bash_completions.d/tmux

curl -o ~/bin/pwclient -J -L http://patchwork.ozlabs.org/pwclient/
chmod +x ~/bin/pwclient
# Install TLDR
curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
chmod +x ~/bin/tldr

