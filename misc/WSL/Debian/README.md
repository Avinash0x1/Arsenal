- #### Setup
> - **Passwordless**
 ```bash
 echo -e "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a "/etc/sudoers"
 sudo apt-get update -y -qq
 ```

> - **Upgrade**
```bash
!#Upgrade PKGs & Deps
 sudo apt-get update -y -qq ; sudo apt-get dist-upgrade -y -qq ; sudo apt-get upgrade -y -qq
 sudo apt install \
 apt-transport-https apt-utils bash bash-completion build-essential ca-certificates coreutils curl fakeroot file fuse git gnupg2 gpg-agent htop jq kmod less lsof moreutils nano ntp pciutils procps psmisc rsync software-properties-common sudo supervisor tar tmux util-linux xterm wget zip -y -qq
 sudo apt full-upgrade -y -qq

!#Cleanup
 sudo apt autoremove -y -qq
 sudo apt autoclean -y -qq

!#Upgrade Distro
 sudo nano "/etc/apt/sources.list"
 #https://www.debian.org/releases/
 `
 #Change bookworm to whatever is he newest version, and also replace http with https (ca-certificates)
 deb https://deb.debian.org/debian bookworm main
 deb https://deb.debian.org/debian bookworm-updates main
 deb https://security.debian.org/debian-security bookworm-security main
 deb https://ftp.debian.org/debian bookworm-backports main
 `

!#Upgrade PKGs & Deps (again)
 sudo umount -l "/lib/modules/"
 sudo apt-get update -y -qq ; sudo apt-get dist-upgrade -y -qq ; sudo apt-get upgrade -y -qq
 sudo apt full-upgrade -y -qq ; sudo apt autoremove -y -qq ; sudo apt autoclean -y -qq

!#Check
 sudo reboot # or wsl --terminate "Debian"
#After Reboot
 sudo mount -l "/lib/modules/"
 lsb_release -a || cat "/etc/os-release"

!#If Stable packages are too old
#Switch to Testing (Good Enough) or Unstable (Dangerous)
 sudo nano "/etc/apt/sources.list"
 #https://www.debian.org/releases/
 `
 #Change bookworm to testing
 deb https://deb.debian.org/debian testing main
 deb https://deb.debian.org/debian testing-updates main
 deb https://security.debian.org/debian-security testing-security main
 deb https://ftp.debian.org/debian testing-backports main
 `
 sudo umount -l "/lib/modules/"
 sudo apt-get update -y -qq ; sudo apt-get dist-upgrade -y -qq ; sudo apt-get upgrade -y -qq
 sudo apt full-upgrade -y -qq ; sudo apt autoremove -y -qq ; sudo apt autoclean -y -qq
!#Check
 sudo reboot # or wsl --terminate "Debian"
#After Reboot
 sudo mount -l "/lib/modules/"
 lsb_release -a || cat "/etc/os-release"
```

> - **TimeZone**
```bash
!# Replace Asia/Kathmandu with yours
 sudo apt-get update -y && sudo DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata
 sudo ln -fs "/usr/share/zoneinfo/Asia/Kathmandu" "/etc/localtime"
 sudo dpkg-reconfigure --frontend noninteractive tzdata
 sudo apt-get update -y
```

> - **CoreUtils**
 ```bash
 !# May need to run this Twice
 sudo apt install \
 apt-transport-https apt-utils bash bash-completion build-essential ca-certificates coreutils curl dos2unix \
 fakeroot file fuse git gnupg2 gpg-agent htop jq kmod less lsof moreutils nano ntp pciutils procps psmisc \
 rsync software-properties-common sudo supervisor tar tmux util-linux xterm wget zip -y -qq

 !# Networking
 sudo apt-get install dnsutils 'inetutils*' net-tools netcat-traditional -y
 sudo apt-get install 'iputils*' -y
 !# Fix Perms for ping
 sudo setcap cap_net_raw+ep "$(which ping)"
 ```
> - **IP Forwarding**
```bash
 echo 'net.ipv4.ip_forward = 1' | sudo tee -a "/etc/sysctl.conf"
 echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a "/etc/sysctl.conf"
 sudo sysctl -p "/etc/sysctl.conf"
```
> - **ufw Firewall**
```bash
!# Install ufw
sudo apt-get -y install ufw

!# Enable ufw
sudo ufw enable && sudo ufw status

!# Check Rules
sudo ufw status numbered

!# Add new rules
# Example: Allow 7330/7331/7332 Ports
sudo ufw allow 7330/tcp
sudo ufw allow out 7330/tcp
sudo ufw allow 7330/udp
sudo ufw allow out 7330/udp
sudo ufw allow 7331/tcp
sudo ufw allow out 7331/tcp
sudo ufw allow 7331/udp
sudo ufw allow out 7331/udp
sudo ufw allow 7332/tcp
sudo ufw allow out 7332/tcp
sudo ufw allow 7332/udp
sudo ufw allow out 7332/udp
!# Recheck
sudo ufw reload
sudo ufw status numbered
```
> - **Systemd**
 ```bash
 !# Enable SystemD : https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/
 echo -e "[boot]\nsystemd=true" | sudo tee "/etc/wsl.conf"
 sudo dos2unix "/etc/wsl.conf"
 !# Reboot WSL (Run this from Windows Terminal)
 wsl --shutdown
 !# Install Core
 sudo apt-get -y install systemd systemd-resolved
 !# Reboot WSL Again (Run this from Windows Terminal)
 wsl --shutdown
 !# Re Login
 wsl -d debian
 !# Check Status
 systemctl list-unit-files --type=service
 sudo systemctl status "time-sync.target"
 ```
---
- #### Install Addons & Utils
- ##### Minimal (Recommended)
```bash
# bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Arsenal/main/misc/Linux/install_bb_tools.sh")
bash <(curl -qfsSL "https://pub.ajam.dev/repos/Azathothas/Arsenal/misc/Linux/install_bb_tools.sh")
```
- ##### [**Static-Bins**](https://github.com/Azathothas/Toolpacks) (Optional)
 ```bash
 !# SKIP THIS IF YOU INTEND TO ALSO RUN THE CUSTOMIZE SCRIPT (BELOW)
!# eget & 7z (DEPS)
 sudo curl -qfsSL "https://bin.ajam.dev/x86_64_Linux/eget" -o "/usr/local/bin/eget" && sudo chmod +xwr "/usr/local/bin/eget"
 sudo eget "https://bin.ajam.dev/x86_64_Linux/7z" --to "/usr/local/bin/7z"
!# Toolpacks (>500 Tools)
  #wget "$(curl -qfsSL "https://api.github.com/repos/Azathothas/Toolpacks/releases" | jq -r '.[] | select(.assets[].name | contains("x86_64")) | .assets[].browser_download_url' | grep -i '.7z$' | sort -u | tail -n 1)" -O "./toolpack_x86_64.7z"
  wget --quiet --show-progress --progress="dot:giga" "https://bin.ajam.dev/x86_64_Linux/_toolpack_x86_64.7z" -O "./toolpack_x86_64.7z"
  mkdir -p "$HOME/bin" ; 7z e "./toolpack_x86_64.7z" -o"$HOME/bin" -y && rm -rf "$HOME/bin/toolpack_x86_64" 2>/dev/null && rm -rf "./toolpack_x86_64.7z" ; chmod +xwr $HOME/bin/*
 !# You may need to Remove | Symlink Certain things
 !# Example: sudo rm "/usr/local/bin/git" # (As git doesn't work)
 !# Reinstall git from apt: sudo apt-get install git
 ```
 - ##### [Python (**MiniConda**)](https://docs.conda.io/projects/miniconda/en/latest/) (Essential)
 ```bash
 curl -qfSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o /tmp/install_conda.sh && chmod +xwr "/tmp/install_conda.sh" && /tmp/install_conda.sh -b
 !# Check pip
 export PATH="$HOME/miniconda3/bin:$HOME/miniconda3/condabin:$PATH"
 pip install archey4 ; archey
 !# Edit your $HOME/.bashrc | $HOME/.zshrc and add:
 export PATH="$HOME/miniconda3/bin:$HOME/miniconda3/condabin:$PATH"
 ```
- ##### Install [**Crystal**](https://crystal-lang.org/install/on_ubuntu/) (Optional)
 ```bash
  curl -qfsSL "https://crystal-lang.org/install.sh" | sudo bash
 ```
- ##### Install [**Golang**](https://github.com/kerolloz/go-installer) (Optional)
 ```bash
 !# Install
  bash <(curl -qfsSL "https://git.io/go-installer")
 !# Delete Junk
  rm $HOME/go*.gz
 !# Export PATH (Or simply relogin)
  export PATH=$HOME/.go/bin:$PATH
  export PATH=$HOME/go/bin:$PATH
 ```
- ##### Install [**Nix**](https://github.com/DeterminateSystems/nix-installer) (Optional)
```bash
!# Install
"/nix/nix-installer" uninstall --no-confirm 2>/dev/null
curl -qfsSL "https://install.determinate.systems/nix" | bash -s -- install linux --no-confirm

!# Close/Reopen Sessionn (Terminal)
```
- ##### Install [**Rust**](https://www.rust-lang.org/tools/install) (Optional)
 ```bash
 !# Install
  bash <(curl -qfsSL "https://sh.rustup.rs") -y 
 !# Export PATH (Or simply relogin)
  export PATH=$HOME/.cargo/bin:$PATH
  export PATH=$HOME/.cargo/env:$PATH
 ```
- ##### Install [**Ziglang**](https://ziglang.org/learn/getting-started/) (Optional)
 ```bash
 !# Install
  pushd "$(mktemp -d)" && curl -qfSLJO $(curl -qfsSL "https://ziglang.org/download/index.json" | jq -r '.master | ."x86_64-linux".tarball')
  find . -type f -name '*.tar*' -exec tar -xvf {} \; && sudo mkdir -p "/usr/local/zig" && sudo mv "$(find . -maxdepth 1 -type d | grep -v '^.$')"/* "/usr/local/zig" ; popd
  !# Add this to $HOME/.bashrc | $HOME/.zshrc
  export PATH="/usr/local/zig:/usr/local/zig/lib:/usr/local/zig/lib/include:$PATH"
 ```
---
- #### [**Customize**](https://github.com/Azathothas/Arsenal/blob/main/misc/WSL/Debian/customize.sh) (Optional)
```bash
!# Installs broot + fzf + starship + tailscale + tmux + zsh & more
bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Arsenal/main/misc/WSL/Debian/customize.sh")
!# If that doesn't work then:
wget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/misc/WSL/Debian/customize.sh" && dos2unix "./customize.sh" && chmod +xwr "./customize.sh"
!# Edit your $HOME/.zshrc and update certain things (Example: Username etc)
!# Also add the miniconda path
```
 ```bash
 !# Final PATH in $HOME/.bashrc || $HOME/.zshrc
 #PATHS (Only Required)
 export GOROOT="$HOME/.go"
 export GOPATH="$HOME/go"
 export PATH="$HOME/bin:$HOME/.cargo/bin:$HOME/.cargo/env:$GOROOT/bin:$GOPATH/bin:$HOME/miniconda3/bin:$HOME/miniconda3/condabin:/usr/local/zig:/usr/local/zig/lib:/usr/local/zig/lib/include:$PATH"
 ```
---
