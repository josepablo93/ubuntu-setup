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
  sudo apt-get -y install arc-theme arc-icons

  echo "installing oh-my-zsh!"
  sudo apt-get -y install zsh git-core
  wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  sudo chsh -s `which zsh`
  chsh -s `which zsh`
  echo $SHELL

}

setup_dotfiles(){
  echo "setting up dotfiles"
  rm ~/.zshrc
  rm ~/.config/terminator/config

  ln -s dotfiles/zshrc ~/.zshrc
  ln -s dotfiles/vimrc ~/.vimrc
  ln -s dotfiles/terminator ~/.config/terminator/config

  mkdir -p ~/.vim/autoload ~/.vim/bundle && \
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

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

install_k8s() {
  echo "starting minikube isntallation"
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube-linux-amd64
  sudo mv minikube-linux-amd64 /usr/local/bin/minikube

  echo "installing kubectl"
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  echo "don't forget to do 'minikube start'!"
}

install_vm(){
  echo "installing kvm"
  sudo apt -y install qemu qemu-kvm libvirt-bin bridge-utils virt-manager
  sudo service libvirtd start
  sudo update-rc.d libvirtd enable
}

install_vs_code(){
  echo "installing vs code"
  sudo snap install --classic code
}

install_nodejs(){
  echo "installing nodeJs"
  curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
  sudo apt-get install -y nodejs
}

install_rust(){
  echo "installing rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
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
  install_nodejs
  install_rust
  
  echo "we are done! Please reboot your machine"
}

main
