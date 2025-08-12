# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download zinit if it is not there
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add fzf
if command -v fzf > /dev/null 2>&1 || "$HOME/.bin/update_fzf"; then
  zinit light Aloxaf/fzf-tab
fi

# Add eza
if command -v eza > /dev/null 2>&1 || "$HOME/.bin/update_eza"; then
  zinit ice from'gh-r' as'program' sbin'**/eza -> eza' atclone'cp -vf completions/eza.zsh _eza'
  zinit light eza-community/eza
  zinit light z-shell/zsh-eza
fi

# Add snippets
zinit snippet OMZP::sudo

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# History
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(fzf --zsh)"

# Create .rc file if not exists in user directory
if [ ! -e ~/.rc ]; then
  touch ~/.rc
fi

CURRENT_SHELL=zsh

# Source ~/.rc file (it should contain user specific sources so user does not touch this file)
source ~/.rc

nvm_dir="$HOME/.nvm"
if [ -d nvm_dir ]; then
  export NVM_DIR="$nvm_dir"
  [ ! -s "$NVM_DIR/nvm.sh" ] || \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ ! -s "$NVM_DIR/bash_completion" ] || \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi


# Load Angular CLI autocompletion.
if command -v ng > /dev/null 2>&1; then
  source <(ng completion script)
fi

# ROS2
if command -v register-python-argcomplete3 > /dev/null 2>&1; then
  if command -v ros2 > /dev/null 2>&1; then
    eval "$(register-python-argcomplete3 ros2)"
  fi
  if command -v colcon > /dev/null 2>&1; then
    eval "$(register-python-argcomplete3 colcon)"
  fi
fi

# Create autocompletions directory
COMPLETIONS_DIR=$HOME/.zfunc
[ -d $COMPLETIONS_DIR ] || mkdir $COMPLETIONS_DIR
fpath+=$COMPLETIONS_DIR

if command -v rustup &> /dev/null; then
  [ -s $COMPLETIONS_DIR/_rustup ] || rustup completions zsh rustup > $COMPLETIONS_DIR/_rustup
  [ -s $COMPLETIONS_DIR/_cargo ] || rustup completions zsh cargo > $COMPLETIONS_DIR/_cargo
fi

[ -s $COMPLETIONS_DIR/_spotify_player ] || ! command -v spotify_player &> /dev/null || spotify_player generate zsh > $COMPLETIONS_DIR/_spotify_player

# Load autocompletions
autoload -U compinit && compinit
