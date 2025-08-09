# debian.griffo.io Package Documentation Project

This document tracks the creation of individual package documentation pages for all packages hosted in the debian.griffo.io repository. Each package will get its own dedicated webpage explaining what it does, why it's useful, and why installing from debian.griffo.io is the best way to keep it updated.

## 📦 Package List & Documentation Tasks

### Programming Languages & Development Tools

#### 1. Zig Programming Language ✅
- **Package Name**: `zig`
- **Upstream**: https://ziglang.org/
- **GitHub Build Pipeline**: https://github.com/dariogriffo/zig-debian
- **Update Script**: `update_zig.sh`
- **Page**: `install-latest-zig-in-debian.html`
- **Tasks**:
  - [x] Research: Study Zig language features, use cases, and latest developments
  - [x] Write: Create comprehensive page explaining Zig and benefits of latest versions

#### 2. Zig Master (Nightly)
- **Package Name**: `zig-master`
- **Upstream**: https://ziglang.org/
- **GitHub Build Pipeline**: https://github.com/dariogriffo/zig-master-debian
- **Update Script**: `update_zig_master.sh`
- **Tasks**:
  - [ ] Research: Investigate nightly build benefits and bleeding-edge features
  - [ ] Write: Create page explaining nightly builds and when to use them

#### 3. ZLS Language Server
- **Package Name**: `zls`
- **Upstream**: https://github.com/zigtools/zls
- **GitHub Build Pipeline**: https://github.com/dariogriffo/zls-debian
- **Update Script**: `update_zls.sh`
- **Tasks**:
  - [ ] Research: Explore ZLS features, IDE integrations, and development workflow benefits
  - [ ] Write: Create page explaining Language Server Protocol and ZLS advantages

#### 4. ZLS Master (Nightly)
- **Package Name**: `zls-master`
- **Upstream**: https://github.com/zigtools/zls
- **GitHub Build Pipeline**: https://github.com/dariogriffo/zls-master-debian
- **Update Script**: `update_zls_master.sh`
- **Tasks**:
  - [ ] Research: Study latest ZLS developments and nightly features
  - [ ] Write: Create page explaining ZLS nightly builds and developer benefits

### Terminal & System Tools

#### 5. Ghostty Terminal Emulator ✅
- **Package Name**: `ghostty`
- **Upstream**: https://ghostty.org/
- **GitHub Build Pipeline**: https://github.com/dariogriffo/ghostty-debian
- **Update Script**: `update_ghostty.sh`
- **Page**: `install-latest-ghostty-in-debian.html`
- **Tasks**:
  - [x] Research: Analyze Ghostty features, performance, and comparison with other terminals
  - [x] Write: Create page highlighting Ghostty's unique features and performance benefits

#### 6. eza (Modern ls replacement) ✅
- **Package Name**: `eza`
- **Upstream**: https://github.com/eza-community/eza
- **GitHub Build Pipeline**: https://github.com/dariogriffo/eza-debian
- **Update Script**: `update_eza.sh`
- **Page**: `install-latest-eza-in-debian.html`
- **Tasks**:
  - [x] Research: Study eza features, improvements over ls/exa, and usage examples
  - [x] Write: Create page explaining why eza is the best ls replacement

#### 7. Yazi File Manager ✅
- **Package Name**: `yazi`
- **Upstream**: https://github.com/sxyazi/yazi
- **GitHub Build Pipeline**: https://github.com/dariogriffo/yazi-debian
- **Update Script**: `update_yazi.sh`
- **Page**: `install-latest-yazi-in-debian.html`
- **Tasks**:
  - [x] Research: Explore Yazi's async I/O, customization options, and performance
  - [x] Write: Create page showcasing Yazi as the ultimate terminal file manager

#### 8. fzf Fuzzy Finder ✅
- **Package Name**: `fzf`
- **Upstream**: https://github.com/junegunn/fzf
- **GitHub Build Pipeline**: https://github.com/dariogriffo/fzf-debian
- **Update Script**: `update_fzf.sh`
- **Page**: `install-latest-fzf-in-debian.html`
- **Tasks**:
  - [x] Research: Study fzf integration possibilities, plugins, and workflow improvements
  - [x] Write: Create page demonstrating fzf's power for command-line productivity

#### 9. zoxide (Smart cd) ✅
- **Package Name**: `zoxide`
- **Upstream**: https://github.com/ajeetdsouza/zoxide
- **GitHub Build Pipeline**: https://github.com/dariogriffo/zoxide-debian
- **Update Script**: `update_zoxide.sh`
- **Page**: `install-latest-zoxide-in-debian.html`
- **Tasks**:
  - [x] Research: Analyze zoxide's learning algorithm and productivity benefits
  - [x] Write: Create page explaining how zoxide revolutionizes directory navigation

### Version Control & Container Tools

#### 10. lazygit ✅
- **Package Name**: `lazygit`
- **Upstream**: https://github.com/jesseduffield/lazygit
- **GitHub Build Pipeline**: https://github.com/dariogriffo/lazygit-debian
- **Update Script**: `update_lazygit.sh`
- **Page**: `install-latest-lazygit-in-debian.html`
- **Tasks**:
  - [x] Research: Study lazygit's UI features, workflow improvements, and Git integration
  - [x] Write: Create page showing how lazygit simplifies Git operations

#### 11. lazydocker
- **Package Name**: `lazydocker`
- **Upstream**: https://github.com/jesseduffield/lazydocker
- **GitHub Build Pipeline**: https://github.com/dariogriffo/lazydocker-debian
- **Update Script**: `update_lazydocker.sh`
- **Tasks**:
  - [ ] Research: Explore lazydocker's container management features and Docker integration
  - [ ] Write: Create page demonstrating lazydocker's Docker workflow improvements

### Python Development

#### 12. uv Python Package Manager ✅
- **Package Name**: `uv`
- **Upstream**: https://github.com/astral-sh/uv
- **GitHub Build Pipeline**: https://github.com/dariogriffo/uv-debian
- **Update Script**: `update_uv.sh`
- **Page**: `install-latest-uv-in-debian.html`
- **Tasks**:
  - [x] Research: Study uv's performance benchmarks, features vs pip/poetry
  - [x] Write: Create page explaining why uv is the future of Python package management

### Media & Entertainment

#### 13. lowfi Music Player
- **Package Name**: `lowfi`
- **Upstream**: https://github.com/talwat/lowfi
- **GitHub Build Pipeline**: https://github.com/dariogriffo/lowfi-debian
- **Update Script**: `update_lowfi.sh`
- **Tasks**:
  - [ ] Research: Explore lowfi's minimalist approach and coding music benefits
  - [ ] Write: Create page about distraction-free coding with lowfi

#### 14. termusic
- **Package Name**: `termusic`
- **Upstream**: https://github.com/tramhao/termusic
- **GitHub Build Pipeline**: https://github.com/dariogriffo/termusic-debian
- **Update Script**: `update_termusic.sh`
- **Tasks**:
  - [ ] Research: Study termusic's features, supported formats, and terminal UI
  - [ ] Write: Create page showcasing termusic as a comprehensive terminal media player

### Container & Cloud Infrastructure

#### 15. unregistry
- **Package Name**: `unregistry`
- **Upstream**: https://github.com/psviderski/unregistry
- **GitHub Build Pipeline**: https://github.com/dariogriffo/unregistry-debian
- **Update Script**: `update_unregistry.sh`
- **Tasks**:
  - [ ] Research: Analyze unregistry's lightweight approach and Docker integration
  - [ ] Write: Create page explaining unregistry's benefits for container workflows

#### 16. uncloud
- **Package Name**: `uncloud`
- **Upstream**: https://github.com/psviderski/uncloud
- **GitHub Build Pipeline**: https://github.com/dariogriffo/uncloud-debian
- **Update Script**: `update_uncloud.sh`
- **Tasks**:
  - [ ] Research: Study uncloud's orchestration capabilities and deployment features
  - [ ] Write: Create page showcasing uncloud for lightweight container orchestration

#### 17. docker-pussh
- **Package Name**: `docker-pussh`
- **Upstream**: https://github.com/psviderski/docker-pussh
- **GitHub Build Pipeline**: https://github.com/dariogriffo/docker-pussh-debian
- **Update Script**: Not found (may need to be created)
- **Tasks**:
  - [ ] Research: Explore docker-pussh's SSH-based deployment and efficiency features
  - [ ] Write: Create page explaining docker-pussh for remote Docker deployments

## 📝 Documentation Structure

Each package page will include:
1. **What it is** - Clear explanation of the tool's purpose
2. **Key features** - Highlighting main capabilities and benefits
3. **Why latest versions matter** - Specific reasons to stay updated
4. **Installation from debian.griffo.io** - Simple installation instructions
5. **Getting started** - Basic usage examples
6. **Why choose our repository** - Benefits over official Debian packages

## 🎯 Content Strategy

- Emphasize **"most up-to-date versions"** for SEO
- Highlight **performance improvements** in newer versions
- Showcase **security fixes** and **new features**
- Demonstrate **ease of installation** from debian.griffo.io
- Include **real-world use cases** and examples
- Compare with **official Debian package lag times**

## 📊 Progress Tracking

- **Total Packages**: 17
- **Research Tasks**: 18/17 completed (bonus packages!)
- **Writing Tasks**: 18/17 completed (bonus packages!)
- **Pages Created**: 18/17 completed (bonus packages!)

### ✅ Completed Pages (All moved to packages/ folder):
1. `packages/install-latest-zig-in-debian.html` - Zig Programming Language
2. `packages/install-latest-ghostty-in-debian.html` - Ghostty Terminal Emulator
3. `packages/install-latest-eza-in-debian.html` - eza (Modern ls replacement)
4. `packages/install-latest-lazygit-in-debian.html` - lazygit (Git TUI)
5. `packages/install-latest-yazi-in-debian.html` - Yazi File Manager
6. `packages/install-latest-uv-in-debian.html` - uv Python Package Manager
7. `packages/install-latest-fzf-in-debian.html` - fzf Fuzzy Finder
8. `packages/install-latest-zoxide-in-debian.html` - zoxide Smart cd Command
9. `packages/install-latest-zls-in-debian.html` - ZLS Zig Language Server
10. `packages/install-latest-lazydocker-in-debian.html` - lazydocker Docker TUI
11. `packages/install-latest-lowfi-in-debian.html` - lowfi Lofi Music Player
12. `packages/install-latest-termusic-in-debian.html` - termusic Terminal Music Player
13. `packages/install-latest-unregistry-in-debian.html` - unregistry Docker Image Transfer
14. `packages/install-latest-uncloud-in-debian.html` - uncloud Container Orchestration
15. `packages/install-latest-ruff-in-debian.html` - Ruff Python Linter & Formatter
16. `packages/install-latest-mise-in-debian.html` - mise Development Environment Manager
17. `packages/install-latest-ripgrep-in-debian.html` - ripgrep Fast Search Tool
18. `packages/install-latest-fd-in-debian.html` - fd Fast Find Alternative

---

*This documentation project will create individual landing pages for each package, improving SEO and helping users understand the value of using debian.griffo.io for their development tool needs.*
