#!/bin/bash
#
# Auto Instalador do agreSSive Framework
# Um sistema completo para criação e administração de rádios usando o ShoutCast e sc_trans!
# Por: Lucas Saliés Brum, a.k.a. sistematico <lucas AT archlinux DOT com DOT br>
# Criado em 05/02/2017
# Alterado em 05/02/2017

if [ "$(id -u)" != "0" ]; then
   echo "Este script deve ser executado apenas como root." 1>&2
   exit 1
fi

echo "Alterando para a pasta /tmp..."
echo

cd /tmp

echo "Clonando o repositório do agreSSive..."
echo

git clone -q https://github.com/sistematico/agressive

echo "Entrando na pasta /tmp/agressive..."
echo
cd agressive

read -p "Qual será o nome do usuário que vai rodar o agreSSive?" usuario_raw

echo
echo "Sanitizando o nome de usuário..."

# first, strip underscores
limpo=${usuario_raw//_/}
# next, replace spaces with underscores
limpo=${limpo// /_}
# now, clean out anything that's not alphanumeric or an underscore
limpo=${limpo//[^a-zA-Z0-9_]/}
# finally, lowercase with TR
usuario=$(echo -n $limpo | tr A-Z a-z)

if [ -d $(eval echo "~${usuario}") ]; then
  echo "Este usuário ou a paste dele já existe, deseja sobre-escrever?"

  # while true; do
      read -p "Este usuário ou a paste dele já existe, deseja sobre-escrever? [s/n] " yn
      case $yn in
          #[Ss]* ) make install; break;;
          [Ss]* ) break;;
          [Nn]* ) echo "Abortando a execução do agreSSive..." && exit 1;;
          *) echo "Por favor, responda sim ou não.";;
      esac
  #done
else
  read -sp "Senha do usuário e do agreSSive?" senha_raw
  senha=$(perl -e 'print crypt($ARGV[0], "senha_raw")' $senha_raw)
fi

caminho=$(eval echo ~${usuario})

echo
echo "Seguem os dados de instalação:"
echo "---------------------------------------------"
echo "Usuário: ${usuario}"
echo "Senha: $pass"
echo "Caminho: ${caminho}"
echo "---------------------------------------------"
echo

#while true; do
    read -p "Deseja continuar? [s/n] " yn
    case $yn in
        #[Ss]* ) make install; break;;
        [Ss]* ) break;;
        [Nn]* ) echo "Abortando a execução do agreSSive..." && exit 1;;
        *) echo "Por favor, responda sim ou não.";;
    esac
#done

#useradd -m -p encryptedPassword username
