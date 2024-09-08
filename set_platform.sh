#/bin/bash

############ NOTAS ############

## SOLO HACE EL SETUP HASTA NGNIX

## LAS IMAGENES DE LOS CONTAINERS YA ESTAN EN EL SERVIDOR

############ VARS ############

# production or development
ENV="development"

# same as set_conf.sh
FOLDER_NAME="deployment"

cd $HOME
cd ..
cd $FOLDER_NAME
mkdir -p "data" "letsencrypt"
mkdir github

cd github
git clone https://github.com/proyecto-arima/deployment.git
cp docker-compose.yml ../
mv .env.template ../.env

cd ..
cd $FOLDER_NAME

echo "###############################################"
echo "docker compose config"
docker compose config
echo "###############################################"

echo "###############################################"
echo "nginx docker compose up"
echo "###############################################"

# web server
docker compose --profile deploy up -d

echo "###############################################"
echo "RECORDA COMPLETAR EL .ENV ANTES DE EJECUTAR 'docker compose --profile <service> up -d' para el resto"
echo "###############################################"

echo "###############################################"
echo "RECORDA LEVANTAR MANUALMENTE EL CONTAINER la web y el backend. luego se debera hacer auto por CI/CD"
echo "###############################################"

exit 0
