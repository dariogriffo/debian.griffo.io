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

Packages are build in the following repos
[ghostty-build](https://github.com/ghostty-debian/build-pipeline)
[lazydocker-build](https://github.com/lazydocker-debian/build-pipeline)

Currently supported debian distros are:
- Bookworm
- Trixie
- Sid

This is an unofficial community project to provide deb packages for tooling that are not provided officially by Debian

## Add the repository to your sources.list

```sh
curl -sS https://debian.griffo.io/3B9335DF576D3D58059C6AA50B56A1A69762E9FF.asc | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/debian.griffo.io.list
```

## Install packages

```sh
apt install -y lazydocker
apt install -y ghostty
```

## Disclaimer

- This repo is not open for issues related to the tools provided, please refer to the owners for that.

