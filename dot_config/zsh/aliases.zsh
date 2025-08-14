## ls shortcuts
alias ll='ls -lh'
alias lla='ls -lha'

# folder shortcuts
alias oasis="$HOME/github/oasis"
alias home='~'  
alias config="$HOME/github/config"
alias code='code-insiders'

## git shortcuts
alias gl="git pull"
alias gp="git push"
alias gs="cd $HOME/github/ && $HOME/github/config-station/scripts/git/mgitstatus.sh && cd -"

## chezmo shortcuts
alias c="chezmoi"
alias ce="chezmoi edit"
alias cc="chezmoi cd"
alias cs="chezmoi status"
alias ca="chezmoi add"
alias cra="chezmoi re-add" # re-add all previously added files even when the target has changes

## lazy git shortcut
alias lg="lazygit"

# set neovim as default editor
alias vim="nvim"
alias vi="nvim"


# tmux aliasses
alias tns="tmux new-session -s test"
alias tm="tmux has-session -t main 2>/dev/null && tmux attach -t main || tmux new-session -s main"
