#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
files=".tmux.conf .bashrc .bash_aliases .gitignore .gitconfig .vimrc .vim .git-prompt .acd_func"    # list of files/folders to symlink in homedir


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
ln -s $dir/extra/gdb-dashboard/.gdbinit ~/.gdbinit
# Install filepicker
ln -s $dir/extra/PathPicker/fpp ~/bin/fpp

ln -s $dir/extra/tmux-vim-select-pane /bin/tmux-vim-select-pane

# Install Checkpatch
wget -P ~/bin/ https://github.com/torvalds/linux/blob/master/scripts/checkpatch.pl
chmod +x ~/bin/checkpatch.pl

# Install TLDR
curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
chmod +x ~/bin/tldr

