# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository managed with [chezmoi](https://chezmoi.io), containing comprehensive system configurations for macOS and Linux development environments. The repository uses chezmoi's templating system to handle cross-platform differences and machine-specific configurations.

## Chezmoi Architecture

### File Naming Convention
Chezmoi uses special prefixes in the source directory that map to actual files:
- `dot_` → `.` (dotfiles)
- `private_` → files with restricted permissions
- `executable_` → executable files
- `run_once_` → scripts that run once during apply
- `run_onchange_` → scripts that run when their content changes

Example: `dot_config/zsh/executable_dot_zshrc` → `~/.config/zsh/.zshrc` (executable)

### Key Directories
- **Source directory**: `~/.local/share/chezmoi/` (this repository)
- **Target directory**: `~` (where configs are applied)
- **Templates**: Files ending in `.tmpl` are processed through chezmoi's template engine

### Chezmoi Commands

```bash
# Apply changes from source to target
chezmoi apply

# Edit a file (opens in $EDITOR, automatically adds to source)
chezmoi edit ~/.config/zsh/.zshrc

# See what would change without applying
chezmoi diff

# Update from remote repository and apply
chezmoi update

# Add a new file to chezmoi
chezmoi add ~/.config/newfile

# Check for differences between source and target
chezmoi status
```

## Configuration Structure

### XDG Base Directory Compliance
This system strictly follows the XDG Base Directory Specification:
- **Config**: `~/.config/` (set by `$XDG_CONFIG_HOME`)
- **Data**: `~/.local/share/`
- **Cache**: `~/.cache/`
- **State**: `~/.local/state/`

⚠️ **IMPORTANT**: Configuration files are in `~/.config/<tool>/`, NOT in home directory root.

### Shell (Zsh)
- **Config location**: `~/.config/zsh/`
- **Entry point**: `~/.zshenv` (sets XDG paths and ZDOTDIR)
- **Main config**: `~/.config/zsh/.zshrc`
- **Plugin managers**:
  - zinit (external plugins: powerlevel10k, syntax-highlighting, autosuggestions, autocomplete)
  - oh-my-zsh (built-in plugins: git, pip, macos, etc.)
- **Auto-start behavior**: Automatically attaches to tmux session "main" on interactive login

⚠️ **zsh-autocomplete conflicts**: zsh-autocomplete MUST be loaded AFTER oh-my-zsh to prevent arrow key keybinding conflicts. See `dot_config/zsh/executable_dot_zshrc:42-43`

### Tmux
- **Config location**: `~/.config/tmux/tmux.conf`
- **Plugin manager**: TPM (tmux plugin manager)
- **Key plugins**: vim-tmux-navigator, catppuccin theme, tmux-resurrect, tmux-continuum
- **Prefix key**: `C-SPACE` (not default C-b)
- **Auto-restore**: Sessions automatically restore on startup via tmux-continuum

### Neovim
- **Config location**: `~/.config/nvim/`
- **Distribution**: LazyVim (https://lazyvim.github.io)
- **Plugin manager**: lazy.nvim
- **Custom plugins**: Located in `lua/plugins/` directory
- **Integration**: Configured with tmux-navigator for seamless tmux/vim pane navigation

### macOS Window Management

#### Yabai (Tiling Window Manager)
- **Config location**: `~/.config/yabai/yabairc`
- **Layout**: BSP (binary space partitioning)
- **Dynamic padding**: Automatically adjusts padding based on:
  - Wide displays (≥3440px): Adds substantial padding for single/dual windows
  - Number of visible windows on current space
- **Floating apps**: iTerm2, Stats, Activity Monitor, NordVPN configured to float
- **Window sizing**: Custom signals for iTerm2 and Strongbox positioning
- **Startup**: Creates up to 4 spaces automatically

#### Hammerspoon (macOS Automation)
- **Config location**: `~/.config/hammerspoon/`
- **Setup**: Requires setting config path via:
  ```bash
  defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
  ```
- **Modules**: hotkeys, screen_resolution

#### Karabiner (Keyboard Customization)
- **Config location**: `~/.config/karabiner/`

### Package Management

Packages are defined in `.chezmoidata/packages.yaml` with platform-specific lists:
- **macOS**: Homebrew (brews + casks)
- **Linux**: apt packages + manual installations (gh, pyenv, lazygit)

Package installation triggered by `run_onchange_install-packages.sh.tmpl` when package list changes.

### External Dependencies

External repositories managed via `.chezmoiexternal.toml`:
- oh-my-zsh → `~/.config/zsh/oh-my-zsh/`
- zinit → `~/.local/share/zinit/zinit.git/`
- TPM → `~/.config/tmux/plugins/tpm/`

These refresh weekly (168h period).

## Development Workflow

### Making Configuration Changes

1. **Edit configs through chezmoi**:
   ```bash
   chezmoi edit ~/.config/zsh/.zshrc
   # This opens: ~/.local/share/chezmoi/dot_config/zsh/executable_dot_zshrc
   ```

2. **Or edit source directly**:
   ```bash
   cd ~/.local/share/chezmoi
   # Edit files with appropriate naming (dot_, executable_, etc.)
   chezmoi apply  # Apply changes
   ```

3. **Test changes**:
   ```bash
   chezmoi diff  # Preview changes
   chezmoi apply  # Apply changes
   ```

4. **Commit to repository**:
   ```bash
   cd ~/.local/share/chezmoi
   git add .
   git commit -m "description"
   git push
   ```

### Adding New Tools

1. Add package to `.chezmoidata/packages.yaml`
2. Add configuration files with proper naming:
   ```bash
   chezmoi add ~/.config/newtool/config
   ```
3. If tool needs initialization, create script in `.chezmoiscripts/`:
   - `run_once_*.sh` for one-time setup
   - `run_onchange_*.sh.tmpl` for updates when content changes

### Cross-Platform Templating

Use chezmoi templates for platform-specific configs:
```
{{ if eq .chezmoi.os "darwin" -}}
# macOS specific
{{ else if eq .chezmoi.os "linux" -}}
# Linux specific
{{ end -}}
```

See `.chezmoiignore.tmpl` for examples of conditional file inclusion.

## SSH Configuration

- **SSH agent**: Strongbox password manager provides SSH agent
- **Socket location**: `~/.config/strongbox/agent.sock`
- **Environment variable**: `SSH_AUTH_SOCK` set in `.zshrc`

## Testing & Verification

After making changes:

1. **Test configuration syntax**:
   ```bash
   # Zsh
   zsh -n ~/.config/zsh/.zshrc

   # Tmux
   tmux source-file ~/.config/tmux/tmux.conf
   ```

2. **Verify chezmoi state**:
   ```bash
   chezmoi status  # Check for differences
   chezmoi verify  # Verify target state matches source
   ```

3. **Fresh apply test**:
   ```bash
   chezmoi apply --dry-run --verbose
   ```

## Common Gotchas

1. **Tmux session startup issues**: If tmux auto-attach fails, check for stale sockets in `/tmp/`
2. **Yabai requires SIP modifications**: Some features require disabling System Integrity Protection on macOS
3. **Homebrew path differences**: Different paths for Apple Silicon vs Intel Macs (handled in `.zshenv`)
4. **Plugin load order**: zsh-autocomplete must load after oh-my-zsh
5. **Hammerspoon config path**: Must be set via `defaults write` (not automatic)
