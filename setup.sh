#!/usr/bin/env bash

set -Eeuo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"

install_system_dependencies() {
  local packages=()

  command -v curl >/dev/null 2>&1 || packages+=(curl)
  command -v git >/dev/null 2>&1 || packages+=(git)
  command -v tmux >/dev/null 2>&1 || packages+=(tmux)
  command -v zsh >/dev/null 2>&1 || packages+=(zsh)

  ((${#packages[@]} == 0)) && return

  if ! command -v apt-get >/dev/null 2>&1; then
    printf 'Missing required commands: %s\n' "${packages[*]}" >&2
    printf 'Install them with your system package manager, then rerun setup.sh.\n' >&2
    exit 1
  fi

  if ((EUID == 0)); then
    apt-get install -y "${packages[@]}"
  elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get install -y "${packages[@]}"
  else
    printf 'Installing required packages needs root access.\n' >&2
    exit 1
  fi
}

clone_if_missing() {
  local repository="$1"
  local destination="$2"

  if [[ -d "$destination/.git" ]]; then
    return
  fi

  if [[ -e "$destination" ]]; then
    printf 'Cannot clone %s: %s already exists and is not a Git repository.\n' \
      "$repository" "$destination" >&2
    exit 1
  fi

  mkdir -p "$(dirname -- "$destination")"
  git clone --depth=1 "$repository" "$destination"
}

install_starship() {
  if command -v starship >/dev/null 2>&1 ||
    [[ -x "$HOME/.local/bin/starship" ]]; then
    return
  fi

  curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
}

install_zinit() {
  clone_if_missing \
    https://github.com/zdharma-continuum/zinit.git \
    "$ZINIT_HOME"
}

install_tmux_config() {
  clone_if_missing \
    https://github.com/gpakosz/.tmux.git \
    "$HOME/.tmux"
  ln -sfn "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
}

install_vim_config() {
  local vim_runtime="$HOME/.vim_runtime"
  local colorscheme="$vim_runtime/colors/onehalfdark.vim"
  local vim_config="$vim_runtime/my_configs.vim"

  clone_if_missing \
    https://github.com/amix/vimrc.git \
    "$vim_runtime"
  sh "$vim_runtime/install_awesome_vimrc.sh"

  if [[ ! -s "$colorscheme" ]]; then
    mkdir -p "$(dirname -- "$colorscheme")"
    curl -fsSL \
      https://raw.githubusercontent.com/sonph/onehalf/master/vim/colors/onehalfdark.vim \
      -o "$colorscheme"
  fi

  if ! grep -qxF 'colorscheme onehalfdark' "$vim_config" 2>/dev/null; then
    printf '\ncolorscheme onehalfdark\n' >> "$vim_config"
  fi
}

install_pnpm() {
  local pnpm_home="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"

  if command -v pnpm >/dev/null 2>&1 ||
    [[ -x "$pnpm_home/pnpm" ]]; then
    return
  fi

  curl -fsSL https://get.pnpm.io/install.sh | sh -
}

install_dotfiles() {
  mkdir -p "$HOME/.config" "$HOME/.vim_runtime"
  cp -R "$DOTFILES_DIR/.config/." "$HOME/.config/"
  cp "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
  cp "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  cp "$DOTFILES_DIR/.vim_runtime/my_configs.vim" "$HOME/.vim_runtime/my_configs.vim"
  cp "$DOTFILES_DIR/.tmux.conf.local" "$HOME/.tmux.conf.local"
}

main() {
  install_system_dependencies
  install_starship
  install_zinit
  install_tmux_config
  install_vim_config
  install_pnpm
  install_dotfiles

  printf 'Dotfiles installed. Start a new zsh session to load the configuration.\n'
}

main "$@"
