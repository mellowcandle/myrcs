#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
files=".tmux.conf .bashrc .bash_aliases .gitignore .gitconfig .vimrc .vim .git-prompt .acd_func"    # list of files/folders to symlink in homedir

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
sudo ln -s $dir/extra/PathPicker/fpp /usr/local/bin/fpp

# Install Checkpatch
sudo wget -P /usr/local/bin/ https://github.com/torvalds/linux/blob/master/scripts/checkpatch.pl
sudo chmod +x /usr/local/bin/checkpatch.pl

# Install TLDR
sudo curl -o /usr/local/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
sudo chmod +x /usr/local/bin/tldr

