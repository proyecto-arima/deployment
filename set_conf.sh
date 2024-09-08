#/bin/bash

############ NOTAS ############

## USAR debian con arq. x86_64 para el script

## USAR con sudo y usuario generico el script, dado que se instalan o cambian configs de la VM para las operaciones

## CONFIGURAR las variables de config. antes de ejecutar el script (no usar parametros $1, $2, etc)

############ VARS ############

export CR_PAT="MY_GITHUB_TOKEN"
export CR_USER="MY_GITHUB_USER"

# production or development
ENV="development"

# same as set_platform.sh
FOLDER_NAME="project-deployment"

cd $HOME
mkdir -p "../$FOLDER_NAME"
cd ..
cd $FOLDER_NAME

if [ -z "$CR_PAT" ]
then
    echo "CR_PAT is empty"
    exit 1
fi

if [ -z "$CR_USER" ]
then
    echo "CR_USER is empty"
    exit 1
fi

if [ -z "$ENV" ]
then
    echo "ENV is empty"
    exit 1
fi

##############################################################################################################

# Update and upgrade
echo "###############################################"
echo "Updating and upgrading"
sudo apt update
sudo apt upgrade
echo "###############################################"

# Install docker.io to ghcr.io
echo "###############################################"
echo "Installing docker.io"
sudo apt install -y docker.io
sudo groupadd docker
sudo usermod -aG docker $USER
sudo chmod 660 /var/run/docker.sock
echo "###############################################"

# Docker install
# Add Docker's official GPG key
echo "###############################################"
echo "Adding Docker's official GPG key and repository"
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "###############################################"

# Add the repository to Apt sources
echo "###############################################"
echo "Installing Docker"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker
sudo systemctl enable docker
echo "###############################################"

##############################################################################################################

# Download images with auth.
echo "###############################################"
echo "Authenticating to ghcr.io"
echo $CR_PAT | docker login ghcr.io -u $MY_GITHUB_USER --password-stdin

if ENV=production
then
    echo "Downloading images for production"
    docker pull ghcr.io/proyecto-arima/backend:latest
    docker pull ghcr.io/proyecto-arima/webapp:latest
fi

if ENV=testing
then
    echo "Downloading images for testing"
    docker pull ghcr.io/proyecto-arima/backend:latest-test
    docker pull ghcr.io/proyecto-arima/webapp:latest-test
fi
echo "###############################################"

# Download other public images
echo "###############################################"
echo "Downloading other public images"
docker pull mongo:latest
docker pull jc21/nginx-proxy-manager:latest
docker pull portainer/portainer-ce:latest
echo "###############################################"

## Docker compose install
echo "###############################################"
echo "Installing docker-compose"
sudo apt-get update
sudo apt-get install docker-compose-plugin
echo "###############################################"

## Other packages installations
echo "###############################################"
echo "Installing other packages"

# infra debug
sudo apt install htop

# debug local
apt install npm

echo "###############################################"
echo "Intallation completed"
echo "###############################################"
exit 0
