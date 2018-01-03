#!/bin/bash

# Install Docker:
#  from: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/

# 1: Uninstall old versions
sudo apt-get remove -y \
	docker \
	docker-engine \
	docker.io

# 2: Update Apt-get, and install reqs
sudo apt-get update && \
sudo apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common

# 3: Add the official Docker GPG Key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# 3.1: Verify the key
key_verify=`sudo apt-key fingerprint 0EBFCD88 | grep 'Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88'`
if [[ "$key_verify" = "" ]]; then
  echo "Cannot verify Docker Install, see: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository"
  exit 1
fi

# 4: Add the Docker Repo:
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# 5: Actually install Docker
#  On production systems, you should install a specific version of Docker CE instead of always using the latest. 

docker_version="17.12.0~ce-0~ubuntu"
sudo apt-get update -y && \
sudo apt-get install -y docker-ce=$docker_version

# 5.1: Verify docker install
docker_verify=`sudo docker run hello-world | grep 'Hello from Docker!'`
if [[ "$docker_verify" = "" ]]; then
  echo "Cannot verify Docker Install, see: https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository"
  exit 1
else
  echo "Docker Install Successful!, Installing docker-compose"
fi

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Install Docker Compose:
#   from: https://docs.docker.com/compose/install/#install-compose
docker_compose_version=1.18.0
docker_compose_url=https://github.com/docker/compose/releases/download/$docker_compose_version/docker-compose-`uname -s`-`uname -m`
docker_compose_dest=/usr/local/bin/docker-compose

sudo curl -L $docker_compose_url -o $docker_compose_dest
sudo chmod +x $docker_compose_dest

docker_compose_verify=`docker-compose --version | grep "docker-compose version $docker_compose_version"`
if [[ "$docker_compose_verify" = "" ]]; then
  echo "Cannot verify Docker Compose Installation, see: https://docs.docker.com/compose/install/#install-compose"
  exit 1
else
  echo "docker-compose verions $docker_compose_version Install Successful!"
fi
