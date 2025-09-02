<div align="center">
  <a href="https://github.com/juanMarinero/watcher_tree_files/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome"></a>
  <a href="https://github.com/juanMarinero/watcher_tree_files/blob/master/LICENSE"><img src="https://img.shields.io/github/license/juanMarinero/watcher_tree_files" alt="LICENSE"></a>
  <img src="https://img.shields.io/badge/Zsh-F15A24?logo=zsh&logoColor=fff" alt="ZSH">
  <img src="https://img.shields.io/badge/-Linux-grey?logo=linux" alt="Linux">
</div>
<br/>


# 🕵️🗂️ A file event watcher

File event watcher that detects changes and visually compares directory hierarchies for easy diffing.


## Installation

```sh
git clone https://github.com/juanMarinero/watcher_tree_files.git ~/.watcher_tree_files
echo 'export PATH="$HOME/.watcher_tree_files/bin:$PATH"' >> ~/.bashrc # or ~/.zshrc
```

## Usage

```sh
cd <path>
watcher_tree_files
```

Options:

```
--help
--version
--which
--debug
-v, --verbose
-d, --directory <path>
```
