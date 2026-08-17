#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

set -euo pipefail

APT_INSTALLS=(cmake silversearcher-ag tree git manpages-dev manpages-posix-dev tmux tcputils
	exuberant-ctags minicom gvim curl u-boot-tools p7zip-full device-tree-compiler python-pip
	flex bison astyle ripgrep git-secret)
PACMAN_INSTALLS=(perl-net-smtp-ssl perl-authen-sasl perl-mime-tools ctags gvim git tmux
	base-devel minicom xsel bat the_silver_searcher ripgrep)
FEDORA_INSTALLS=(cmake tree git tmux tcputils ctags minicom gvim curl p7zip man-pages dtc
	python-pip flex bison astyle autoconf automake ncurses-devel uboot-tools ripgrep git-secret)
# Amazon Linux 2023 reports ID_LIKE=fedora but ships a much smaller package
# set than Fedora, so it needs its own list rather than FEDORA_INSTALLS:
#   - no gvim (no X11 vim build), use the console build
#   - python-pip is python3-pip
#   - p7zip-full is 7zip + 7zip-standalone: the p7zip packages are still in the
#     repository at 16.02 but are obsoleted by 7zip, so asking for p7zip left
#     rpm -q p7zip reporting nothing while /usr/bin/7z came from 7zip 25.01
#   - no minicom, tcputils, uboot-tools, astyle, git-secret, the_silver_searcher
#   - no ripgrep, bat or fzf either, those are installed from upstream releases
# gcc/make/unzip are explicit here because install_cscope builds from source,
# and git-lfs because .gitconfig declares the lfs filter as required.
AMZN_INSTALLS=(cmake tree git tmux ctags cscope curl unzip man-pages dtc python3-pip flex
	bison autoconf automake gcc gcc-c++ make ncurses-devel 7zip 7zip-standalone vim-enhanced
	bash-completion git-lfs)

dir=$PWD                    # dotfiles directory
olddir=~/.dotfiles_old      # old dotfiles backup directory
# Files and folders to symlink into the home directory. Keep this in sync with
# the repository: a name that is not here creates a dangling symlink in ~.
# .tmux.conf is deliberately absent, it is linked out of extra/.tmux below, and
# so is .pwclientrc, which is machine local and listed in .gitignore.
files=(.bashrc .bash_aliases .bash_arch .gitignore .gitconfig .gitconfig_gmail
	.gitconfig_intel .gitconfig_linaro .vimrc .vim .git-prompt .acd_func .ripgreprc)

function pacman_install()
{
		local tmp
		sudo -E pacman -Syyu
		sudo -E pacman -Sy "${PACMAN_INSTALLS[@]}"

		# Install yay
		if command -v yay >/dev/null 2>&1; then
				return 0
		fi
		tmp=$(mktemp -d) || return 0
		(
				cd "$tmp" &&
				git clone https://aur.archlinux.org/yay.git &&
				cd yay &&
				makepkg --noconfirm -si
		) || echo "WARNING: couldn't build yay, skipping" >&2
		rm -rf "$tmp"
}

function apt_install()
{
		sudo -E apt-get update
		sudo -E apt-get install -y "${APT_INSTALLS[@]}"
}

function dnf_install()
{
		sudo -E dnf install -y "${FEDORA_INSTALLS[@]}"
}

function amzn_install()
{
		# strict=0 keeps the whole transaction from being aborted by a single
		# package that a future Amazon Linux release happens to drop.
		sudo -E dnf install -y --setopt=strict=0 "${AMZN_INSTALLS[@]}"
}

function github_latest_release()
{
		local url
		# Resolve the tag from the releases/latest redirect rather than from
		# api.github.com, which allows 60 unauthenticated requests an hour per
		# source address. Behind a shared NAT or proxy that budget covers every
		# machine using the address, so it is frequently already spent, and the
		# lookup then returns nothing at all: bat and fzf were skipped with a
		# warning while ripgrep, already on PATH, appeared fine.
		url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
				"https://github.com/$1/releases/latest" 2>/dev/null) || return 0
		# A repository with no releases lands on /releases, with no tag to take.
		case "$url" in
				*/releases/tag/*) printf '%s\n' "${url##*/}" ;;
		esac
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
# already provides. ~/bin is checked directly because .bashrc is what puts it
# on PATH, so a rerun from a shell that has not sourced it yet would otherwise
# download everything again.
function binary_installed()
{
		if command -v "$1" >/dev/null 2>&1; then
				echo "$1 is already on PATH, skipping"
				return 0
		fi
		if [ -x "$HOME/bin/$1" ]; then
				echo "$1 is already in $HOME/bin, skipping"
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
		if ! tar -xzf "$tmp/release.tar.gz" -C "$tmp"; then
				echo "WARNING: couldn't unpack $url, skipping $binary" >&2
				rm -rf "$tmp"
				return 0
		fi
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
		local tmp
		# Amazon Linux 2023 and Fedora both package cscope, so this only builds
		# where there is nothing to use.
		if binary_installed cscope; then
				return 0
		fi
		tmp=$(mktemp -d) || return 0
		# Build in a scratch directory rather than mkdir tmp inside the
		# repository, which failed outright if the directory was already there
		# and left the shell parked in a directory that then got removed.
		if ! curl -fsSL -o "$tmp/cscope-master.zip" \
				https://github.com/mellowcandle/cscope/archive/master.zip; then
				echo "WARNING: couldn't download cscope, skipping" >&2
				rm -rf "$tmp"
				return 0
		fi
		(
				cd "$tmp" &&
				unzip -q cscope-master.zip &&
				cd cscope-master &&
				autoreconf -i &&
				./configure &&
				make -j"$(nproc)" &&
				sudo make install
		) || echo "WARNING: couldn't build cscope, skipping" >&2
		rm -rf "$tmp"
}

function install_bat()
{
		local ver triple
		if binary_installed bat; then
				return 0
		fi
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
		if binary_installed rg; then
				return 0
		fi
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
		if binary_installed fzf; then
				return 0
		fi
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

function install_pwclient()
{
		if binary_installed pwclient; then
				return 0
		fi
		if ! command -v python3 >/dev/null 2>&1; then
				echo "WARNING: no python3, skipping pwclient" >&2
				return 0
		fi
		python3 -m pip install --user pwclient || {
				echo "WARNING: couldn't install pwclient from PyPI, skipping" >&2
				return 0
		}
		# .bashrc only puts ~/bin on PATH, so surface the pip script there.
		if [ -x "${PYTHONUSERBASE:-$HOME/.local}/bin/pwclient" ]; then
				mkdir -p "$HOME/bin"
				ln -s -f "${PYTHONUSERBASE:-$HOME/.local}/bin/pwclient" "$HOME/bin/pwclient"
		fi
}

# A provisioned machine ships a ~/.bashrc carrying setup that exists nowhere
# else: PATH entries for site local tool directories, shell completions,
# wrapper functions and language environments such as cargo. Filing
# it away in ~/.dotfiles_old and linking ours over the top silently loses all
# of it. Our .bashrc sources ~/.bashrc.local before it sets anything of its
# own, so seed that from whatever was already there.
function preserve_local_bashrc()
{
		local existing="$HOME/.bashrc"
		# Already a symlink means we installed before, so there is nothing
		# machine specific left to rescue.
		if [ -L "$existing" ] || [ ! -f "$existing" ]; then
				return 0
		fi
		if [ -e "$HOME/.bashrc.local" ]; then
				echo "$HOME/.bashrc.local already exists, leaving it alone"
				return 0
		fi
		echo "Keeping the existing $HOME/.bashrc as $HOME/.bashrc.local"
		cp "$existing" "$HOME/.bashrc.local"
}

function install_vim()
{
		if ! command -v vim >/dev/null 2>&1; then
				echo "WARNING: no vim on PATH, skipping plugin install" >&2
				return 0
		fi
		vim +BundleInstall +qall || echo "WARNING: vim plugin install failed" >&2
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
mkdir -p "$olddir"
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd "$dir"
echo "...done"

preserve_local_bashrc

# Move any existing dotfile aside, then symlink. A file that is already the
# link we want is left alone: without that check a second run moved our own
# symlinks into $olddir, overwriting the backup of the real file with a link
# to the file that replaced it.
for file in "${files[@]}"; do
    target=~/"$file"
    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$dir/$file")" ]; then
        echo "$target is already linked, skipping"
        continue
    fi
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Moving existing ~/$file to $olddir"
        mv "$target" "$olddir/"
    fi
    echo "Creating symlink to $file in home directory."
    ln -s "$dir/$file" "$target"
done

# .gdbinit is in a special directory
ln -s -f "$dir/extra/gdb-dashboard/.gdbinit" ~/.gdbinit
# Install filepicker
ln -s -f "$dir/extra/PathPicker/fpp" ~/bin/fpp
ln -s -f "$dir/extra/diff-so-fancy/diff-so-fancy" ~/bin/diff-so-fancy

ln -s -f "$dir/extra/tmux-vim-select-pane" ~/bin/tmux-vim-select-pane
ln -s -f "$dir/extra/.tmux/.tmux.conf" ~/.tmux.conf
# .tmux.conf.local is meant to be edited in place, so never overwrite one that
# is already there.
if [ -e ~/.tmux.conf.local ]; then
    echo "$HOME/.tmux.conf.local already exists, leaving it alone"
else
    cp "$dir/extra/.tmux/.tmux.conf.local" ~/
fi

# bash-completion 2.3 and later read this directory, so the completions no
# longer need root, and /etc/bash_completions.d never existed anyway.
completion_dir="${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion/completions"
mkdir -p "$completion_dir"
ln -s -f "$dir/extra/tmux-bash-completion/completions/tmux" "$completion_dir/tmux"

# Install pwclient. patchwork.ozlabs.org stopped serving the script and now
# answers /pwclient/ with an HTML 404 page, which the old curl wrote straight
# to ~/bin/pwclient and marked executable. It lives on PyPI these days.
install_pwclient

# Install TLDR
curl -fsSL -o ~/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr &&
		chmod +x ~/bin/tldr ||
		echo "WARNING: couldn't download tldr, skipping" >&2

install_ripgrep
install_bat
install_fzf
install_cscope
install_vim
