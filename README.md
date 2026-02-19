<h1>
   <p align="center">
     <a href="https://github.com/dariogriffo/"><img src="https://github.com/dariogriffo/debian.griffo.io/blob/main/logo.webp" alt="Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/debian.griffo.io/blob/main/debian-logo.webp" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>Unoffical Debian packages hosted by me.
   </p>
</h1>

# What is this repo??

This repository contains _unofficial_ Debian packages (.deb) for the **most up-to-date versions** of popular development tools:

- [Zig](https://ziglang.org/) - General-purpose programming language and toolchain
- [ZLS](https://github.com/zigtools/zls) - Language Server Protocol for Zig
- [Ghostty](https://ghostty.org) - Fast, feature-rich terminal emulator
- [lazydocker](https://github.com/jesseduffield/lazydocker/) - Terminal UI for Docker
- [lazygit](https://github.com/jesseduffield/lazygit/) - Terminal UI for Git
- [eza](https://github.com/eza-community/eza) - Modern replacement for 'ls' command
- [lowfi](https://github.com/talwat/lowfi) - Minimalist lofi music player
- [yazi](https://github.com/sxyazi/yazi/) - Terminal file manager written in Rust
- [uv](https://github.com/astral-sh/uv/) - Extremely fast Python package manager
- [fzf](https://github.com/junegunn/fzf/) - Command-line fuzzy finder
- [zoxide](https://github.com/ajeetdsouza/zoxide/) - Smarter cd command
- [termusic](https://github.com/tramhao/termusic/) - Terminal music and podcast player
- [unregistry](https://github.com/psviderski/unregistry/) - Lightweight container registry
- [uncloud](https://github.com/psviderski/uncloud/) - Container orchestration tool
- [docker-pussh](https://github.com/psviderski/docker-pussh/) - Push Docker images over SSH
- [Ulauncher](https://ulauncher.io/) - Application launcher for Linux
- [Bun](https://bun.sh/) - Fast all-in-one JavaScript runtime
- [TigerBeetle](https://tigerbeetle.com/) - Distributed financial transactions database

Since Debian has a freeze and slow release policy, this repository provides **the latest versions** of these tools, updated automatically when new releases are available upstream.

## 🔧 Build Pipelines

Each package is built through dedicated GitHub repositories with automated CI/CD:

- [zig-debian](https://github.com/dariogriffo/zig-debian) - Zig stable releases
- [zig-master-debian](https://github.com/dariogriffo/zig-master-debian) - Zig nightly builds
- [zls-debian](https://github.com/dariogriffo/zls-debian) - ZLS stable releases
- [zls-master-debian](https://github.com/dariogriffo/zls-master-debian) - ZLS nightly builds
- [ghostty-debian](https://github.com/dariogriffo/ghostty-debian/) - Ghostty terminal
- [lazydocker-debian](https://github.com/dariogriffo/lazydocker-debian/) - Docker TUI
- [lazygit-debian](https://github.com/dariogriffo/lazygit-debian/) - Git TUI
- [eza-debian](https://github.com/dariogriffo/eza-debian/) - Modern ls replacement
- [lowfi-debian](https://github.com/dariogriffo/lowfi-debian/) - Lofi music player
- [yazi-debian](https://github.com/dariogriffo/yazi-debian/) - Terminal file manager
- [uv-debian](https://github.com/dariogriffo/uv-debian/) - Python package manager
- [fzf-debian](https://github.com/dariogriffo/fzf-debian/) - Fuzzy finder
- [zoxide-debian](https://github.com/dariogriffo/zoxide-debian/) - Smart cd command
- [termusic-debian](https://github.com/dariogriffo/termusic-debian/) - Terminal music player
- [unregistry-debian](https://github.com/dariogriffo/unregistry-debian) - Container registry
- [uncloud-debian](https://github.com/dariogriffo/uncloud-debian) - Container orchestration
- [docker-pussh-debian](https://github.com/dariogriffo/docker-pussh-debian) - Docker over SSH
- [ulauncher-debian](https://github.com/dariogriffo/ulauncher-debian) - Application launcher
- [bun-debian](https://github.com/dariogriffo/bun-debian) - JavaScript runtime
- [tigerbeetle-debian](https://github.com/dariogriffo/tigerbeetle-debian) - Financial database

## 🐧 Supported Debian Distributions

- **Bookworm** (Debian 12 - oldstable)
- **Trixie** (Debian 13 - stable)
- **Forky** (Debian 14 - testing)
- **Sid** (unstable)

This is an unofficial community project providing **the most up-to-date versions** of development tools as properly packaged Debian packages, filling the gap between fast-moving upstream releases and Debian's stable packaging cycle.

## 🚀 Quick Setup

### Add the repository to your sources.list

```bash
# Add repository GPG key
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg

# Add repository to sources
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list

# Update package list
sudo apt update
```

### Install packages

```bash
# Programming Languages & Tools
sudo apt install -y zig          # Latest stable Zig
sudo apt install -y zig-master   # Nightly Zig builds
sudo apt install -y zls          # Zig Language Server (stable)
sudo apt install -y zls-master   # Zig Language Server (nightly)

# Terminal & File Management
sudo apt install -y ghostty      # Modern terminal emulator
sudo apt install -y eza          # Modern ls replacement
sudo apt install -y yazi         # Terminal file manager
sudo apt install -y fzf          # Fuzzy finder
sudo apt install -y zoxide       # Smart cd command

# Development Tools
sudo apt install -y lazygit      # Git terminal UI
sudo apt install -y lazydocker   # Docker terminal UI
sudo apt install -y uv           # Fast Python package manager

# Media & Entertainment
sudo apt install -y lowfi        # Lofi music player
sudo apt install -y termusic     # Terminal music player

# Container & Cloud Tools
sudo apt install -y unregistry   # Container registry
sudo apt install -y uncloud      # Container orchestration
sudo apt install -y docker-pussh # Docker over SSH

# Application Launchers & Runtimes
sudo apt install -y ulauncher    # Application launcher
sudo apt install -y bun          # JavaScript runtime
sudo apt install -y bun-one      # Bun with single binary
sudo apt install -y bun-profile  # Bun with profile support

# Databases
sudo apt install -y tigerbeetle  # Financial transactions database

# Install everything at once
sudo apt install -y zig ghostty lazygit lazydocker eza yazi uv fzf zoxide lowfi termusic ulauncher bun tigerbeetle
```

## ⚠️ Important Information

### Disclaimer
This repository focuses exclusively on **unofficial Debian packaging**. For issues with the tools themselves, please contact the respective upstream projects. We only handle packaging-related concerns.

### Key Features
- ✅ **Always up-to-date** - Packages updated automatically when new versions are released
- ✅ **Multiple distributions** - Support for Bookworm, Trixie, and Sid
- ✅ **Proper packaging** - Follows Debian packaging standards and dependencies
- ✅ **Nightly builds** - Available for Zig and ZLS for cutting-edge features

### Important Notice
📅 **March 4th, 2025** - Public key was updated. Please run the setup commands above to update your system with the new GPG key.

---

**Visit [debian.griffo.io](https://debian.griffo.io) for more information and the latest updates.**


