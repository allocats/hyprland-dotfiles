#!/usr/bin/env bash

if [ ! -d "src" ]; then
  echo "Err! Missing configs!"
  exit 1
fi

if [ ! -f "packages.conf" ]; then
  echo "Err! packages.conf not found! Exiting :c"
  exit 1
fi

source packages.conf

sudo pacman -Syu --noconfirm

if ! command -v yay &> /dev/null; then
  echo "Installing yay"
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git
  cd yay
  echo "building yay yippee"
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed, skipping that oopsy"
fi

is_installed() {
  pacman -Qi "$1" &> /dev/null
}

is_group_installed() {
  pacman -Qg "$1" &> /dev/null
}

install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
      to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then  
    echo "Installing: ${to_install[*]}"
    yay -S "${to_install[@]}"
  fi
} 

install_sddm() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)"
}

install_configs() {
  xdg-user-dir

  cd src 
  cp -r .config .scripts $HOME/
  cd ..
}

install_packages "${desktop_env[@]}"
install_packages "${terminal_stuff[@]}"
install_packages "${dev[@]}"
install_packages "${fonts[@]}"

install_configs
