# ~/.zshenv
# Environment for every zsh invocation: interactive, non-interactive and scripts.
# Keep this file free of output, prompts and interactive-only settings.

typeset -U path

function path_prepend {
  [[ -d "$1" ]] && path=("$1" $path)
}

function path_append {
  [[ -d "$1" ]] && path+=("$1")
}

path_prepend "$HOME/.local/bin"
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
path_prepend "$PNPM_HOME/bin"
path_prepend "$HOME/.local/share/mise/shims"
