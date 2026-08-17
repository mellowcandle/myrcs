# My .rc files

## Installation

```
$ git submodule update --init --recursive
$ ./install.sh
```

`install.sh` detects the distribution from `/etc/os-release` and installs
packages with pacman, apt or dnf. Amazon Linux, Arch, Debian, Ubuntu, Fedora and
RHEL derivatives are recognised. It then symlinks the dotfiles into `$HOME` and
finishes by running `vim +BundleInstall +qall`, so there is no separate plugin
step to run afterwards.

It is safe to rerun: anything already linked is left alone, and the second run
makes no network requests.

Two things worth knowing before the first run:

- Anything it displaces goes to `~/.dotfiles_old`.
- An existing `~/.bashrc` is also copied to `~/.bashrc.local`, which this
  `.bashrc` sources. On a machine with provisioned shell setup, a managed
  workstation for instance, that is what keeps its tool directory PATH
  entries, shell completions and wrapper functions working.

## Amazon Linux 2023

AL2023 reports `ID_LIKE=fedora` but ships a much smaller package set, so it has
its own list in `install.sh`. ripgrep, bat and fzf are not packaged and are
installed from upstream release tarballs into `~/bin`; pwclient comes from PyPI.
See `apt-installs` for the full mapping and for what is simply unavailable.

## Updating the submodules

```
$ git submodule update --remote --rebase
```

This follows whatever default branch each upstream uses. The old
`git submodule foreach git pull --rebase origin master` fails on the three that
have since moved off `master`: PathPicker and tldr-pages are on `main`,
diff-so-fancy is on `next`.
