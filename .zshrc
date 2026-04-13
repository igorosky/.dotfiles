# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

case $- in
    *i*) ;;
      *) return;;
esac

if [ "$VSCODE_INJECTION" -ne '1' ] && [ "$ZED_TERM" != 'true' ] && command -v tmux >/dev/null 2>&1 && [[ ! $TERM =~ screen ]] && [ -z "$TMUX" ]; then
    exec tmux new-session -A -s main
fi

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
bindkey "^H" backward-kill-word
bindkey "^[[3;5~" kill-word

# History
HISTSIZE=10000
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
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -d $realpath ]]; then
    # Directory: eza -> ls
    if command -v git >/dev/null 2>&1; then
      if [[ "$(git -C "$realpath" rev-parse --is-inside-work-tree)" == "true" ]]; then
        git -C "$realpath" -c color.status=always status -sb
        echo "---"
      fi
    fi
    if command -v eza >/dev/null 2>&1; then
      eza -1 --color=always "$realpath"
    else
      ls -1 --color=always "$realpath"
    fi
  elif [[ -f $realpath ]]; then
    case "$realpath" in
      *.zip) unzip -l "$realpath" ;;
      *.tar) tar -tf "$realpath" ;;
      *.tar.gz|*.tgz) tar -ztf "$realpath" ;;
      *.tar.bz2|*.tbz2) tar -jtf "$realpath" ;;
      *.tar.xz|*.txz) tar -Jtf "$realpath" ;;
      *)
        # If not an archive, check if it is a binary or text file
        if [[ $(file -b --mime-encoding "$realpath") == binary ]]; then
          echo "Binary File\n---"
          file "$realpath"
        else
          # Text file: bat -> cat
          if command -v bat >/dev/null 2>&1; then
            bat --color=always --style=numbers --line-range=:500 "$realpath"
          else
            cat "$realpath"
          fi
        fi
        ;;
    esac
  fi'

zstyle ':fzf-tab:complete:*:*' fzf-flags \
  '--height=60%' \
  '--layout=reverse' \
  '--preview-window=right:60%:wrap:hidden' \
  '--bind=ctrl-/:toggle-preview' \
  '--bind=tab:accept'

# Shell integrations
source <(fzf --zsh)

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

if command -v bat &> /dev/null || "$HOME/.bin/update_bat"; then
  [ -s $COMPLETIONS_DIR/_bat ] || bat --completion=zsh > $COMPLETIONS_DIR/_bat
fi

[ -s $COMPLETIONS_DIR/_spotify_player ] || ! command -v spotify_player &> /dev/null || spotify_player generate zsh > $COMPLETIONS_DIR/_spotify_player
[ -s $COMPLETIONS_DIR/_git-lfs ] || ! command -v git-lfs &> /dev/null || git-lfs completion zsh > $COMPLETIONS_DIR/_git-lfs
[ -s $COMPLETIONS_DIR/_ast-grep ] || ! command -v ast-grep &> /dev/null || ast-grep completions zsh > $COMPLETIONS_DIR/_ast-grep

# Load autocompletions
autoload -Uz compinit && compinit
