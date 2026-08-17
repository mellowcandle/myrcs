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
# Files and folders to symlink into the home directory. Keep this in sync with
# the repository: a name that is not here creates a dangling symlink in ~.
# .tmux.conf is deliberately absent, it is linked out of extra/.tmux below, and
# so is .pwclientrc, which is machine local and listed in .gitignore.
files=".bashrc .bash_aliases .bash_arch .gitignore .gitconfig .gitconfig_gmail .gitconfig_intel .gitconfig_linaro .vimrc .vim .git-prompt .acd_func .ripgreprc"

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

# ripgrep, bat and fzf have no Amazon Linux 2023 package, but all three publish
# statically linked release binaries, so pull those into ~/bin instead.
function rust_target_triple()
{
		case "$(uname -m)" in
				x86_64)  echo "x86_64-unknown-linux-musl" ;;
				aarch64) echo "aarch64-unknown-linux-musl" ;;
				*)
						echo "WARNING: no static release build for $(uname -m), skipping" >&2
						;;
		esac
}

# Skips work for tools the distribution, or another directory on PATH,
# already provides.
function binary_installed()
{
		if command -v "$1" >/dev/null 2>&1; then
				echo "$1 is already on PATH, skipping"
				return 0
		fi
		return 1
}

# install_release_tarball <url> <binary>
function install_release_tarball()
{
		local url="$1" binary="$2" tmp found
		tmp=$(mktemp -d) || return 0
		if ! curl -fsSL -o "$tmp/release.tar.gz" "$url"; then
				echo "WARNING: couldn't download $url, skipping $binary" >&2
				rm -rf "$tmp"
				return 0
		fi
		tar -xzf "$tmp/release.tar.gz" -C "$tmp"
		# Layouts differ between projects: some tarballs keep the binary at the
		# top level, others inside a versioned directory.
		found=$(find "$tmp" -type f -name "$binary" -perm -u+x -print -quit)
		if [ -z "$found" ]; then
				echo "WARNING: no $binary binary inside $url, skipping" >&2
				rm -rf "$tmp"
				return 0
		fi
		mkdir -p "$HOME/bin"
		install -m 755 "$found" "$HOME/bin/$binary"
		rm -rf "$tmp"
		echo "Installed $binary to $HOME/bin"
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
		local ver triple
		binary_installed bat && return 0
		triple=$(rust_target_triple)
		[ -n "$triple" ] || return 0
		ver=$(github_latest_release sharkdp/bat)
		if [ -z "$ver" ]; then
				echo "WARNING: couldn't look up the latest bat release, skipping" >&2
				return 0
		fi
		install_release_tarball \
				"https://github.com/sharkdp/bat/releases/download/${ver}/bat-v${ver#v}-${triple}.tar.gz" \
				bat
}

function install_ripgrep()
{
		local ver triple
		binary_installed rg && return 0
		triple=$(rust_target_triple)
		[ -n "$triple" ] || return 0
		ver=$(github_latest_release BurntSushi/ripgrep)
		if [ -z "$ver" ]; then
				echo "WARNING: couldn't look up the latest ripgrep release, skipping" >&2
				return 0
		fi
		install_release_tarball \
				"https://github.com/BurntSushi/ripgrep/releases/download/${ver}/ripgrep-${ver#v}-${triple}.tar.gz" \
				rg
}

function install_fzf()
{
		local ver arch
		binary_installed fzf && return 0
		case "$(uname -m)" in
				x86_64)  arch="amd64" ;;
				aarch64) arch="arm64" ;;
				*)
						echo "WARNING: no fzf release build for $(uname -m), skipping" >&2
						return 0
						;;
		esac
		ver=$(github_latest_release junegunn/fzf)
		if [ -z "$ver" ]; then
				echo "WARNING: couldn't look up the latest fzf release, skipping" >&2
				return 0
		fi
		install_release_tarball \
				"https://github.com/junegunn/fzf/releases/download/${ver}/fzf-${ver#v}-linux_${arch}.tar.gz" \
				fzf
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

# Move any existing dotfile aside, then symlink. A file that is already the
# link we want is left alone: without that check a second run moved our own
# symlinks into $olddir, overwriting the backup of the real file with a link
# to the file that replaced it.
for file in $files; do
    target=~/"$file"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$dir/$file")" ]; then
        echo "~/$file is already linked, skipping"
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Moving existing ~/$file to $olddir"
        mv "$target" "$olddir/"
    fi
    echo "Creating symlink to $file in home directory."
    ln -s "$dir/$file" "$target"
done

# Build and install cscope (my version becuase upstream is shit) */

# .gdbinit is in a special directory
ln -s -f $dir/extra/gdb-dashboard/.gdbinit ~/.gdbinit
# Install filepicker
ln -s -f $dir/extra/PathPicker/fpp ~/bin/fpp
ln -s -f $dir/extra/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy

ln -s -f $dir/extra/tmux-vim-select-pane ~/bin/tmux-vim-select-pane
ln -s -f $dir/extra/.tmux/.tmux.conf ~/.tmux.conf
# .tmux.conf.local is meant to be edited in place, so never overwrite one that
# is already there.
if [ -e ~/.tmux.conf.local ]; then
    echo "~/.tmux.conf.local already exists, leaving it alone"
else
    cp "$dir/extra/.tmux/.tmux.conf.local" ~/
fi

# bash-completion 2.3 and later read this directory, so the completions no
# longer need root, and /etc/bash_completions.d never existed anyway.
completion_dir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -p "$completion_dir"
ln -s -f $dir/extra/tmux-bash-completion/completions/tmux "$completion_dir/tmux"

# Install pwclient
curl -o ~/bin/pwclient -J -L http://patchwork.ozlabs.org/pwclient/
chmod +x ~/bin/pwclient

# Install TLDR
curl -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr
chmod +x ~/bin/tldr

install_ripgrep
install_bat
install_fzf
install_cscope
install_vim
