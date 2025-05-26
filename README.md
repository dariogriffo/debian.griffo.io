<h1>
   <p align="center">
     <a href="https://github.com/dariogriffo/"><img src="https://github.com/dariogriffo/debian.griffo.io/blob/main/logo.png" alt="Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/debian.griffo.io/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>Unoffical Debian packages hosted by me.
   </p>
</h1>

# What is this repo??

This repository contains _unofficial_ Debian packages (.deb) for
- [Ghostty](https://ghostty.org)
- [lazydocker](https://github.com/jesseduffield/lazydocker/)
- [lazygit](https://github.com/jesseduffield/lazygit/)
- [lowfi](https://github.com/talwat/lowfi)
- [yazi](https://github.com/sxyazi/yazi/)
- [uv](https://github.com/astral-sh/uv/)
- [fzf](https://github.com/junegunn/fzf/)
- [zoxide](https://github.com/ajeetdsouza/zoxide/) 

Since Debian has a freeze and slow release policy, while running stable I like to have the below packages updated, and hosted them myself.

- [ghostty-build](https://github.com/dariogriffo/ghostty-debian/)
- [lazydocker-build](https://github.com/dariogriffo/lazydocker-debian/)
- [lazygit-build](https://github.com/dariogriffo/lazygit-debian/)
- [lowfi-build](https://github.com/dariogriffo/lowfi-debian/)
- [yazi-build](https://github.com/dariogriffo/yazi-debian/)
- [uv-build](https://github.com/dariogriffo/uv-debian/)
- [fzf-build](https://github.com/dariogriffo/fzf-debian/)
- [zoxide-build](https://github.com/dariogriffo/zoxide-debian/)



Currently supported debian distros are:
- Bookworm
- Trixie
- Sid

This is an unofficial community project to provide deb packages for tooling that are not provided officially by Debian

## Add the repository to your sources.list

```sh
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
```

## Install packages

```sh
apt install -y yazi
apt install -y lazydocker
apt install -y lazygit
apt install -y lowfi
apt install -y ghostty
apt install -y uv
apt install -y fzf
apt install -y zoxide
```

## Disclaimer

- This repo is not open for issues related to the tools provided, please refer to the owners for that.


## Important Notice

- 4th of March 2025 - Public key changed, please update with the instruction above.


