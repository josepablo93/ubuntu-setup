#!/bin/bash

USERNAME="jp"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

install_dependencies(){
  echo "installing ubuntu main tools and look&feel"
  sudo apt-get -y install git terminator gnome-tweaks vim
  
  echo "installing chrome"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
  
  echo "installing gitkraken"
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo dpkg -i gitkraken-amd64.deb
  
  echo "installing arc theme"
  sudo add-apt-repository ppa:noobslab/themes
  sudo add-apt-repository ppa:noobslab/icons
  sudo apt-get -y update
  sudo apt-get -y install arc-theme arc-icons

  echo "installing oh-my-zsh!"
  sudo apt-get -y install zsh git-core
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  sudo chsh -s `which zsh`
  echo $SHELL

}

setup_dotfiles(){
  echo "setting up dotfiles"
  ln -s dotfiles/zshrc ~/.zshrc
  ln -s dotfiles/vimrc ~/.vimrc
  cp dotfiles/terminator ~/.config/terminator/config
}

install_docker(){
  echo "starting docker installation"
  sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get -y update
  echo "installing docker"
  sudo apt-get -y install docker-ce docker-ce-cli containerd.io
  echo "setting $USERNAME to docker group"
  sudo groupadd docker
  sudo usermod -aG docker $USERNAME
  sudo systemctl enable docker

  echo "starting docker-compose installation"
  sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  docker-compose --version
}

install_vm(){
  echo "installing kvm"
  sudo apt -y install qemu qemu-kvm libvirt-bin bridge-utils virt-manager
  sudo service libvirtd start
  sudo update-rc.d libvirtd enable
}

install_vs_code(){
  echo "installing vs code"
  sudo apt-get -y install code
}

main(){
  echo "starting!"

  sudo apt-get -y update
  sudo apt-get -y upgrade
  install_dependencies
  setup_dotfiles
  install_docker
  install_vm
  install_vs_code

  echo "we are done! Please reboot your machine"
}

main