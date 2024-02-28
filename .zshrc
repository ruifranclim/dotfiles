# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

################################################################################
# Generic helper functions
################################################################################

# Returns whether the given command is executable or aliased.
_has() {
  return $(whence $1 >/dev/null)
}

# Prepend a directory to path, if it exists.
_prepend_to_path() {
  if [ -d $1 ]; then
    path=($1 $path);
  fi
}

# Append a directory to path, if it exists and isn't already in the path.
_append_to_path() {
  if [ -d $1 -a -z ${path[(r)$1]} ]; then
    path=($path $1);
  fi
}

################################################################################
# Modify the path
################################################################################

# Add common bin directories to path.
_prepend_to_path /usr/local/bin
_prepend_to_path /usr/local/sbin
_prepend_to_path $HOME/.local/bin
_prepend_to_path /opt/homebrew/bin

################################################################################
# Oh-My-ZSH prerequisite setup
################################################################################

# Set OMZ installation location.
ZSH=$HOME/.oh-my-zsh
DISABLE_UPDATE_PROMPT=true
# Set zsh theme to be powerlevel10k with patched fontawesome symbols.
POWERLEVEL9K_MODE='nerdfont-v3'
ZSH_THEME='powerlevel10k/powerlevel10k'
# OMZ messes with the ls colors by default. Let's not have it do that.
DISABLE_LS_COLORS=true
export LS_COLORS=

# These are the default OMZ plugins that we'll install.
plugins=(
  artisan
  composer
  git
  brew
  history-substring-search
  colored-man-pages
  vi-mode
  git-auto-fetch
  fd
  ripgrep
  F-Sy-H
  zsh-autosuggestions
  fzf-tab
)

################################################################################
# Editor setup
################################################################################

# Set Vim as the default editor.
export EDITOR="vim"

################################################################################
# Set up other environment variables, aliases, and options
################################################################################

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="bg=italic,underline"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"


# Set shell options.
setopt correct # enable spelling suggestions
setopt rmstarsilent # silence rm * confirmation

# Decrease delay in entering normal mode in shell.
# https://www.johnhawthorn.com/2012/09/vi-escape-delays/
KEYTIMEOUT=15

################################################################################
# Source Oh-My-ZSH.
################################################################################

# All theme and plugin configs must come beforehand.
# Sourcing this may have side-effects, so order matters.
# For the most part, it seems like bindkey gets overwritten.
# Hence they must be after the OMZ sourcing.
source $ZSH/oh-my-zsh.sh

################################################################################
# Actions with side-effects after sourcing Oh-My-ZSH
################################################################################

# Set key bindings.
bindkey -v # vi mode for shell
bindkey -e # enable C-x-e for shell editor
# Key bindings for history search.
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward
# Explicity bind home and end keys (in case of terminal compatibility issues)
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line

################################################################################
# Set up aliases
################################################################################

# The bat executable may sometimes be called batcat on Debian/Ubuntu.
#if _has bat; then
#  alias bat="cat"
#fi

# Use Neovim instead of classic Vim (if available)
if _has nvim; then
  alias vim="nvim"
  alias vi="nvim"
  export EDITOR="nvim"
fi

# Alias `exa` as default `ls` command (if available).
# This must come after OMZ. (The library overwrites this alias.)
if _has exa; then
  alias ls="exa"
fi

# Sail 
alias sail='[ -f sail ] && sail || vendor/bin/sail'
################################################################################
# FZF setup
################################################################################

# Add fzf to path. We use locally-installed versions of fzf.
fzf_paths=(
  "${HOME}/.local/share/nvim/lazy/fzf"
  "${HOME}/.local/share/nvim/site/pack/packer/start/fzf"
  "${HOME}/.vim/plugged/fzf"
)
for fzf_path in "${fzf_paths[@]}"; do
  if [ -d $fzf_path ]; then
    _prepend_to_path "${fzf_path}/bin"
    break
  fi
done

if _has fzf; then
  if _has fd; then
    # Use fd for fzf.
    FZF_DEFAULT_COMMAND='fd --type f --follow --hidden'
    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    # Use fd for fzf directory search.
    FZF_ALT_C_COMMAND='fd --type d --color never'
  fi

  # Display source tree and file preview for CTRL-T and ALT-C.
  if _has tree; then
    # Show subdir tree for directories.
    FZF_ALT_C_OPTS="--preview '(exa --tree --color=always {} || tree -C {}) | head -200'"
  fi

  # Bind alt-j/k/d/u to moving the preview window for fzf.
  FZF_DEFAULT_OPTS="--bind alt-k:preview-up,alt-j:preview-down,alt-u:preview-page-up,alt-d:preview-page-down"

  # Show previews for files and directories.
  # Having `bat` or `highlight` (or any of the other binaries below) installed
  # enables syntax highlighting.
  FZF_CTRL_T_OPTS="--preview '(bat --style=numbers --color=always {} || highlight -O ansi -l {} || coderay {} || rougify {} || cat {}) 2> /dev/null | head -200'"

  # Some basic fzf-tab configs.
  plugins+=(fzf-tab)
  zstyle ':fzf-tab:complete:cd:*' fzf-preview '(exa --tree --color=always $realpath || tree -C $realpath) 2> /dev/null'
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':fzf-tab:*' switch-group ',' '.'
fi


################################################################################
# Set up source files 
################################################################################

# Source fzf scripts via local installation.
# OMZ overwrites some of these scripts, so this must come afterwards.
if _has fzf; then
  source "$HOME/.fzf.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Source local zshrc configs.
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
