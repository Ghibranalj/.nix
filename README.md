# NixOS Configuration Repository

A flake-based NixOS configuration repository that manages multiple systems using Nix flakes and Home Manager for reproducible, declarative system management.

## Architecture Overview

This repository uses **Nix flakes** for reproducible system configurations and **Home Manager** for user-level configuration management. It's designed to manage multiple hosts while sharing common configurations and allowing host-specific customizations.

### Managed Hosts

- `server` - Server configuration
- `vivo` - Vivo laptop configuration  
- `pc` - Desktop PC configuration
- `tuf` - TUF laptop configuration
- `` - TUF laptop configuration
- `media-server` - Media server configuration (without Home Manager)

## Directory Structure

```
├── flake.nix              # Main flake configuration and host definitions
├── home.nix               # Base Home Manager configuration
├── sys/                   # System-wide configurations
│   ├── default.nix        # Common system packages and settings
│   ├── gui.nix            # GUI-related configurations
│   ├── non-gui.nix        # Non-GUI configurations
│   ├── users.nix          # User management
│   ├── powerconf.nix      # Power management settings
│   └── ...                # Other system modules
├── home/                  # User-specific configurations
│   ├── default.nix        # Base Home Manager imports
│   ├── doom.nix           # Doom Emacs configuration
│   ├── hyprland/          # Hyprland window manager settings
│   └── files/             # Dotfiles and config files
│       └── doom/          # Doom Emacs customizations
└── hosts/                 # Host-specific configurations
    ├── {hostname}/
    │   ├── hardware-configuration.nix  # Hardware-specific settings
    │   ├── configuration.nix           # Host-specific system config
    │   └── home.nix                    # Host-specific user config
    └── ...
```

## Key Components

### System Configuration (`sys/`)

Modular system-wide settings including:
- **GUI/Non-GUI configurations** - Desktop environment and terminal setups
- **User management** - System user configuration
- **Power management** - Battery and power settings
- **Development tools** - Git, Neovim, Docker, and other dev tools
- **Locale settings** - Indonesian/English environment configuration

### Home Configuration (`home/`)

User-specific dotfiles and application configurations:
- **Doom Emacs** - Custom Emacs configuration with themes and packages
- **Hyprland** - Window manager configuration and keybindings
- **Terminal tools** - Alacritty, bash, and other terminal configurations
- **Application settings** - GTK themes, Rofi, and other desktop app configs

### Host-Specific Configurations (`hosts/`)

Each host maintains:
- **Hardware configuration** - Auto-generated hardware-specific settings
- **System configuration** - Host-specific system modules and services
- **Home configuration** - User-specific settings for that host

## Usage

### Rebuild Commands

Convenient aliases are defined in `sys/default.nix:87-90`:

```bash
nix-rebuild        # Rebuild current host configuration
nix-update         # Update channels and rebuild system
nix-cleanup        # Clean up old nix garbage
```

### Manual Rebuild

For specific hosts or manual rebuilding:

```bash
# Rebuild current host
sudo nixos-rebuild switch --flake /home/gibi/.nix#$(hostname)

# Rebuild specific host
sudo nixos-rebuild switch --flake /home/gibi/.nix#hostname

# Build configuration without switching
sudo nixos-rebuild build --flake /home/gibi/.nix#hostname

# Test configuration (doesn't persist after reboot)
sudo nixos-rebuild test --flake /home/gibi/.nix#hostname
```

## Features

- **Declarative configuration** - All system state defined in code
- **Reproducible builds** - Same configuration produces identical results
- **Multi-host support** - Single repository manages multiple machines
- **Modular design** - Shared modules reduce duplication
- **Rollback capability** - Easy to revert configuration changes
- **Automatic updates** - Flakes ensure reproducible package versions

## Dependencies

The flake includes several external inputs:
- `nixpkgs` - Main Nix package repository (stable, unstable, and previous versions)
- `home-manager` - User environment management
- `nix-doom-emacs-unstraightened` - Doom Emacs configuration
- `hyprland` - Tiling window manager
- `stylix` - Theme management system
- `nixarr` - Media server configuration templates
- Various other utility flakes for specific functionality

## Locale Configuration

Configured for Indonesian/English bilingual usage:
- System locale: `en_US.UTF-8`
- Regional formats: `id_ID.UTF-8` for address, measurement, currency, etc.
- Timezone: `Asia/Jakarta`
