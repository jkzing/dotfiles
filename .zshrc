# ~/.zshrc
# Interactive zsh configuration.

[[ $- != *i* ]] && return


# ============================================================
# 0. Helpers
# ============================================================

typeset -U path

function path_prepend {
  [[ -d "$1" ]] && path=("$1" $path)
}

function path_append {
  [[ -d "$1" ]] && path+=("$1")
}

function _zshrc_bind_history_keys {
  if (( ! ${+widgets[history-search-multi-word]} )); then
    (( ${+functions[history-search-multi-word]} )) && zle -N history-search-multi-word
  fi

  if (( ${+widgets[history-search-multi-word]} )); then
    bindkey '^R' history-search-multi-word 2>/dev/null
    bindkey -M viins '^R' history-search-multi-word 2>/dev/null
    bindkey -M vicmd '^R' history-search-multi-word 2>/dev/null
  fi

  bindkey '^[[A' up-line-or-search 2>/dev/null
  bindkey '^[[B' down-line-or-search 2>/dev/null
  [[ -n "${terminfo[kcuu1]}" ]] && bindkey "${terminfo[kcuu1]}" up-line-or-search 2>/dev/null
  [[ -n "${terminfo[kcud1]}" ]] && bindkey "${terminfo[kcud1]}" down-line-or-search 2>/dev/null
  bindkey -M viins '^[[A' up-line-or-search 2>/dev/null
  bindkey -M viins '^[[B' down-line-or-search 2>/dev/null
}

function _zshrc_load_starship {
  command -v starship >/dev/null 2>&1 || return

  case "${widgets[zle-keymap-select]-}" in
    user:starship_zle-keymap-select)
      typeset -g _ZSHRC_STARSHIP_INITIALIZED=1
      return
      ;;
    user:starship_zle-keymap-select-wrapped)
      typeset -g _ZSHRC_STARSHIP_INITIALIZED=1
      case "${__starship_preserved_zle_keymap_select:-}" in
        ""|starship_zle-keymap-select|starship_zle-keymap-select-wrapped)
          zle -N zle-keymap-select starship_zle-keymap-select
          ;;
      esac
      return
      ;;
  esac

  [[ -n "${_ZSHRC_STARSHIP_INITIALIZED:-}" ]] && return
  typeset -g _ZSHRC_STARSHIP_INITIALIZED=1

  local cache bin
  cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship/init.zsh"
  bin="$(command -v starship)"
  if [[ ! -s "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    "$bin" init zsh >| "$cache"
  fi

  source "$cache"
}


# ============================================================
# 1. History / options / completion
# ============================================================

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt PROMPT_SUBST

zmodload zsh/complist
zmodload zsh/terminfo

[[ -d "$HOME/.zsh/completions" ]] && fpath=("$HOME/.zsh/completions" "${fpath[@]}")

autoload -Uz compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[-_]=* r:|=*'

ZSH_COMPDUMP="${ZDOTDIR:-$HOME}/.zcompdump-${ZSH_VERSION}"
if [[ -f "$ZSH_COMPDUMP" ]]; then
  compinit -C -d "$ZSH_COMPDUMP"
else
  compinit -u -d "$ZSH_COMPDUMP"
fi


# ============================================================
# 2. Tool initialization
# ============================================================

path_prepend "$HOME/.local/bin"
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
path_prepend "$PNPM_HOME/bin"
path_prepend "$HOME/.local/share/mise/shims"

[[ -r /usr/share/autojump/autojump.sh ]] && source /usr/share/autojump/autojump.sh


# ============================================================
# 3. Zinit
# ============================================================

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -r "$ZINIT_HOME/zinit.zsh" ]]; then
  print -P "%F{33}Installing zinit into $ZINIT_HOME...%f"
  command mkdir -p "${ZINIT_HOME:h}"
  command git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" \
    && print -P "%F{34}zinit installation successful.%f" \
    || print -P "%F{160}zinit clone failed. Plugins will be skipped.%f"
fi

if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit


  # ============================================================
  # 4. Zinit plugins
  # ============================================================

  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)

  zstyle ':history-search-multi-word' highlight-color 'fg=yellow,bold'
  zstyle ':history-search-multi-word' page-size '8'
  zstyle ':plugin:history-search-multi-word' active 'underline'
  zstyle ':plugin:history-search-multi-word' check-paths 'yes'
  zstyle ':plugin:history-search-multi-word' clear-on-cancel 'no'
  zstyle ':plugin:history-search-multi-word' reset-prompt-protect 1
  zstyle ':plugin:history-search-multi-word' synhl 'yes'

  function zvm_config {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_SYSTEM_CLIPBOARD_ENABLED=true
    ZVM_CURSOR_STYLE_ENABLED=true
    ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
    ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  }

  function zvm_after_init {
    _zshrc_bind_history_keys
  }

  function zvm_after_lazy_keybindings {
    _zshrc_bind_history_keys
  }

  # Keep oh-my-zsh git helpers without loading oh-my-zsh itself.
  zstyle ':omz:alpha:lib:git' async-prompt no
  zinit snippet OMZL::git.zsh
  zinit snippet OMZP::git

  # Load vi-mode synchronously so it is ready at the first prompt.
  zinit ice depth=1
  zinit light jeffreytse/zsh-vi-mode

  # Defer non-essential plugins until after the first prompt.
  zinit ice wait lucid atload'_zshrc_bind_history_keys'
  zinit load zdharma-continuum/history-search-multi-word

  zinit ice wait lucid
  zinit light zsh-users/zsh-autosuggestions

  zinit ice wait lucid
  zinit snippet OMZ::lib/clipboard.zsh

  # Syntax highlighting should load after the other interactive widgets.
  zinit ice wait lucid
  zinit light zdharma-continuum/fast-syntax-highlighting

  _zshrc_bind_history_keys
  zinit cdreplay -q
else
  bindkey -v
  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey -M vicmd 'vv' edit-command-line
fi


# ============================================================
# 5. User functions / aliases
# ============================================================

function get_lines {
  local extension="${1:?usage: get_lines <extension>}"
  find . -type f -name "*.${extension}" -not -path '*/node_modules/*' -print0 |
    xargs -0r wc -l
}

alias gitl="git log --decorate --graph --color --date=relative | less"
alias lines=get_lines
alias ll="ls -al"
alias set_tnpm="export npm_config_registry=https://registry.npmmirror.com"
alias set_onpm="export npm_config_registry=https://registry.npmjs.com"
alias zen="zenith"


# ============================================================
# 6. Prompt / local config
# ============================================================

_zshrc_load_starship

# Keep secrets and host-specific overrides in this untracked file.
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
