#!/bin/bash

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

# Microkube bootstrap script
install_core() {
  sudo bash 
apt-get update
apt-get upgrade -y -q
apt-get install -y -q git tmux dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
}


create_user() {
  sudo bash 
  groupadd app
  useradd --create-home --home /home/app --shell /bin/bash \
    --gid app --groups docker,google-sudoers app
}

install_ruby() {
  sudo -u app bash 
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable

}

install_microkube() {
  sudo -u app bash
  cd /home/app
  source /home/app/.rvm/scripts/rvm
  rvm install --quiet-curl 2.5.3
  rvm use --default 2.5.3
  gem install bundler

  git clone https://github.com/rubykube/microkube.git
  cd microkube
  cp $HOME/app.yml config/

  bundle install
  rake render:config
  rake service:all
  rake service:daemons
  rake geth:import
  rake service:cryptonodes

  ./bin/install_webhook
}

install_core
install_docker
create_user
install_ruby
install_microkube
