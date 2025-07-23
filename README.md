# Thomas's Dotfiles

This is my main dotfiles configuration repository, managed with [chezmoi](https://chezmoi.io).

## Quick Setup
```bash
# Install chezmoi and apply configs
chezmoi init thomaskgb/dotfiles
chezmoi apply
```

## Included Configurations

### Core Development Tools
- **Neovim** - Modern LazyVim setup with plugins
- **Tmux** - Terminal multiplexer with themes and plugins  
- **Zsh** - Shell with Oh-My-Zsh and Powerlevel10k theme
- **Git** - Version control with global gitignore patterns
- **FZF** - Fuzzy finder with custom configurations
- **GitHub CLI** - GitHub integration and workflows

### System Tools
- **Ranger** - Terminal file manager
- **LazyGit** - Terminal UI for git operations

### macOS-Specific
- **Hammerspoon** - macOS automation and window management
- **Yabai** - Tiling window manager with dynamic display detection
- **Karabiner** - Advanced keyboard customization

## Features

- **Cross-platform**: Works on macOS and Linux servers
- **Secure**: Sensitive configs marked as private
- **Modern**: Uses latest tooling (LazyVim, chezmoi, etc.)
- **Organized**: Follows XDG Base Directory specification

## Deployment

### New Machine Setup
```bash
# macOS
brew install chezmoi
chezmoi init thomaskgb/dotfiles
chezmoi apply

# Linux
curl -sfL https://get.chezmoi.io | sh
./bin/chezmoi init thomaskgb/dotfiles
./bin/chezmoi apply
```

### Update Existing Setup
```bash
chezmoi update  # Pull latest changes and apply
```

## Background

This configuration replaces my previously created Ansible setup using Jinja2 templates. Chezmoi makes it easier to manage dotfiles across multiple machines while handling machine-specific differences through templating.

The migration prioritized working `~/.config` versions over Ansible templates, ensuring all configurations are battle-tested and currently in use.