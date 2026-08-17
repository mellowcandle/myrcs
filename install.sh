#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

APT_INSTALLS="cmake silversearcher-ag tree git manpages-dev manpages-posix-dev tmux tcputils exuberant-ctags minicom gvim curl u-boot-tools p7zip-full device-tree-compiler python-pip flex bison astyle ripgrep git-secret"
PACMAN_INSTALLS="perl-net-smtp-ssl perl-authen-sasl perl-mime-tools ctags gvim git tmux base-devel minicom xsel bat the_silver_searcher bat ripgrep"
FEDORA_INSTALLS="cmake tree git tmux tcputils ctags minicom gvim curl p7zip man-pages dtc python-pip flex bison astyle autoconf automake ncurses-devel uboot-tools ripgrep git-secret"
# Amazon Linux 2023 reports ID_LIKE=fedora but ships a much smaller package
# set than Fedora, so it needs its own list rather than FEDORA_INSTALLS:
#   - no gvim (no X11 vim build), use the console build
#   - python-pip is python3-pip, p7zip-full is p7zip + p7zip-plugins
#   - no minicom, tcputils, uboot-tools, astyle, git-secret, the_silver_searcher
#   - no ripgrep, bat or fzf either, those are installed from upstream releases
# gcc/make/unzip are explicit here because install_cscope builds from source,
# and git-lfs because .gitconfig declares the lfs filter as required.
AMZN_INSTALLS="cmake tree git tmux ctags cscope curl unzip man-pages dtc python3-pip flex bison autoconf automake gcc gcc-c++ make ncurses-devel p7zip p7zip-plugins vim-enhanced bash-completion git-lfs"

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old      # old dotfiles backup directory
files=".tmux.conf .bashrc .bash_aliases .bash_arch .gitignore .gitconfig .gitconfig_gmail .gitconfig_intel .gitconfig_neureality .vimrc .vim .git-prompt .acd_func .pwclientrc .ripgreprc"    # list of files/folders to symlink in homedir

function pacman_install()
{
		sudo -E pacman -Syyu
		sudo -E pacman -Sy $PACMAN_INSTALLS

		# Install yay
		mkdir tmp
		cd tmp
		git clone https://aur.archlinux.org/yay.git
		cd yay
		makepkg --noconfirm -si
		cd ../..
		rm -rf tmp

}

function apt_install()
{
		sudo -E apt-get update
		sudo -E apt-get install -y $APT_INSTALLS
}

function dnf_install()
{
		sudo -E dnf install -y $FEDORA_INSTALLS
}

function amzn_install()
{
		# strict=0 keeps the whole transaction from being aborted by a single
		# package that a future Amazon Linux release happens to drop.
		sudo -E dnf install -y --setopt=strict=0 $AMZN_INSTALLS
}

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

function install_vim()
{
		vim +BundleInstall +qall
}

########## Variables

if [ ! -f /etc/os-release ]; then
		echo "ERROR: I need the file /etc/os-release to determine what my distribution is..." >&2
		# If you want, you can include older or distribution specific files here...
		exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

# ID is always set, ID_LIKE only on derivatives: Arch and Fedora set no ID_LIKE
# at all, so an unquoted [ $ID_LIKE == ... ] used to die with "unary operator
# expected" there. Match against both fields instead, padded with spaces so
# each entry of the space separated ID_LIKE list can be matched on its own.
case " ${ID:-} ${ID_LIKE:-} " in
		*" amzn "*)
				# Must precede the fedora arm: Amazon Linux is ID_LIKE=fedora.
				echo "Detected Amazon Linux ${VERSION_ID:-}"
				amzn_install
				;;
		*" arch "*)
				echo "Detected Arch based distribution"
				pacman_install
				;;
		*" debian "*|*" ubuntu "*)
				echo "Detected Debian based distribution"
				apt_install
				;;
		*" fedora "*|*" rhel "*)
				echo "Detected Fedora based distribution"
				dnf_install
				;;
		*)
				echo "Couldn't detect Linux distribution: ID='${ID:-}' ID_LIKE='${ID_LIKE:-}'" >&2
				exit 1
				;;
esac

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
sudo ln -s -f $dir/extra/tmux-bash-completion/completions/tmux /etc/bash_completions.d/tmux

# Install pwclient
curl -o ~/bin/pwclient -J -L http://patchwork.ozlabs.org/pwclient/
chmod +x ~/bin/pwclient

# Install TLDR
curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
chmod +x ~/bin/tldr

install_bat
install_cscope
install_vim
