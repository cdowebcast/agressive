#!/bin/bash
#
# Auto Instalador do agreSSive Framework
# Um sistema completo para criação e administração de rádios usando o ShoutCast e sc_trans!
# Por: Lucas Saliés Brum, a.k.a. sistematico <lucas AT archlinux DOT com DOT br>
# Criado em 05/02/2017
# Alterado em 13/05/2017

echo
echo "Bem vindo ao:"
echo '                      ____ ____  _           '
echo '  __ _  __ _ _ __ ___/ ___/ ___|(_)_   _____ '
echo ' / _` |/ _` | '__/ _ \___ \___ \| \ \ / / _ \'
echo '| (_| | (_| | | |  __/___) |__) | |\ V /  __/'
echo ' \__,_|\__, |_|  \___|____/____/|_| \_/ \___|'
echo '       |___/  '
echo

[ "$(id -u)" != "0" ] && echo "Este script deve ser executado apenas como root." 1>&2 && exit 1
[[ "$(find / -iname which)" == "" ]] && echo "which não encontrado. Abortando..." >&2 && exit 1
[ ! -x $(which tmux) ] && echo "tmux não encontrado. Abortando..." >&2 && exit 1
[ ! -x $(which nginx) ] && echo "nginx não encontrado. Abortando..." >&2 && exit 1
[ ! -x $(which git) ] && echo "git não encontrado. Abortando..." >&2 && exit 1

# Vars
AGRESSIVE_USER=${usuario}
HOMEDIR="/home/${usuario}"
SHOUT_HOME="${HOMEDIR}/sc"
TRANS_HOME="${HOMEDIR}/st"
TMUX=$(which tmux)
TRANS_PATH="${HOMEDIR}/musicas"

# Cores
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

VERMELHO='\033[0;31m'
LIMPA='\033[0m'

# Funções
procura_arquivos() {
  if [ "$#" -gt 0 ] && [ ! -e "$1" ]; then
    echo "O arquivo $1 não foi encontrado. Abortando..." >&2
    #return 1
    exit 1
  fi
}

if [ -d /etc/agressive ]; then
  read -p "Foi detectada uma instalação anterior do agreSSive, deseja sobre-escrever? [s/N] " yn
  while true; do
    case $yn in
      [Ss]* ) break;;
      * ) echo "Abortando a execução do agreSSive..." && exit 1;;
    esac
  done
else
  mkdir /etc/agressive
fi

if [[ -x $(which apt-get 2> /dev/null) ]]; then
    sistema="debian"
    webpath="$(dpkg -L nginx-common | grep www | tail -1)/agressive"
    echo -e "Sistema operacional encontrado: ${VERMELHO}DEBIAN${LIMPA}/${VERMELHO}UBUNTU${LIMPA}!"
elif [[ -x $(which pacman 2> /dev/null) ]]; then
    sistema="arch"
    webpath="$(pacman -Qo nginx | grep www | tail -1)/agressive"
    echo -e "Sistema operacional encontrado: ${VERMELHO}ARCH LINUX${LIMPA}!"
elif [[ -x $(which yum 2> /dev/null) ]]; then
    sistema="centos"
    #webpath="$(cat /etc/nginx/nginx.conf | grep root | grep '/' | tail -1)/agressive"
    webpath="/var/www/html/agressive"
    echo -e "Sistema operacional encontrado: ${VERMELHO}CENTOS${LIMPA}!"
else
  echo "Sistema operacional não identificado. Abortando..."
  exit 1
fi

echo
echo "Alterando para a pasta /tmp..."
echo

cd /tmp

echo
echo "Clonando o repositório do agreSSive..."
echo

if [ -d "/tmp/agressive" ]; then
  read -p "A pasta /tmp/agressive já existe, apagar e baixar uma nova? [s/N] " yn
  #yn=$(echo $yn | tr '[A-Z]' '[a-z]')
  if [ "$yn" == "s" ]; then
    rm -rf /tmp/agressive
    git clone https://github.com/sistematico/agressive 2>/dev/null &
    pid=$! # Process Id of the previous running command

    spin='-\|/'

    i=0
    while kill -0 $pid 2>/dev/null
    do
      i=$(( (i+1) %4 ))
      printf "\r [clonando] ${spin:$i:1}"
      sleep .1
    done
  else
    if [ ! -f '/tmp/agressive/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz' ] || [ ! -f '/tmp/agressive/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz' ]; then
      echo "Binários do Shoutcast e/ou sc_trans não encontrados. Abortando..."
      exit 1
    fi
  fi
else
  git clone -q https://github.com/sistematico/agressive 2>/dev/null &
  pid=$! # Process Id of the previous running command

  spin='-\|/'

  i=0
  while kill -0 $pid 2>/dev/null
  do
    i=$(( (i+1) %4 ))
    printf "\r [clonando] ${spin:$i:1}"
    sleep .1
  done
fi

echo
echo "Entrando na pasta /tmp/agressive..."
echo

cd /tmp/agressive

read -p "Qual será o nome do usuário que vai rodar o agreSSive? [Padrão: agressive]" usuario_raw
usuario_raw=${usuario_raw:-"agressive"}

echo
echo "Sanitizando o nome de usuário..."
echo
# underscores
limpo=${usuario_raw//_/}
# spaces with underscores
limpo=${limpo// /_}
# only alphanumeric or an underscore
limpo=${limpo//[^a-zA-Z0-9_]/}
# lowercase
usuario=`echo -n $limpo | tr A-Z a-z`

if [ -d $(eval echo "~${usuario}") ]; then
  read -p "Este usuário ou a pasta dele já existe, deseja sobre-escrever? [s/N] " yn
  while true; do
    case $yn in
      [Ss]* ) break;;
      * ) echo "Abortando a execução do agreSSive..." && exit 1;;
    esac
  done
  caminho=$(eval echo ~${usuario})
else
  read -sp "Senha do usuário e do agreSSive? [Padrão: agressive]" senha_raw
  senha=$(perl -e 'print crypt($ARGV[0], "senha_raw")' $senha_raw)
  caminho="/home/${usuario}"
  senha_raw=${senha_raw:-agressive}
  echo
fi

AGRESSIVE_USER=${usuario}
HOMEDIR="/home/${usuario}"
SHOUT_HOME="${HOMEDIR}/sc"
TRANS_HOME="${HOMEDIR}/st"
TMUX=$(which tmux)
TRANS_PATH="${HOMEDIR}/musicas"
TEMP_PATH="/tmp/agressive"
#SHOUT_BIN="${TEMP_PATH}/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz"
SHOUT_BIN="${TEMP_PATH}/sistema/downloads/sc_serv2_linux_x64-latest.tar.gz"
TRANS_BIN="${TEMP_PATH}/sistema/downloads/sc_trans_linux_x64_10_07_2011.tar.gz"

echo
read -p "Qual será a pasta do agreSSive no servidor Web?? [Padrão: ${webpath}] " webp
webp=${webp:-$webpath}
webpath=$webp

echo
read -p "Usuário padrão do servidor web [Padrão: www-data] " usuario_web
usuario_web=${usuario_web:-"www-data"}

echo
read -p "Grupo padrão do servidor web [Padrão: www-data] " grupo_web
grupo_web=${grupo_web:-"www-data"}

if [[ ! $(grep -q $grupo_web /etc/group) ]]; then
  echo "O grupo $grupo_web não existe, criando..."
  groupadd $grupo_web
fi

echo
echo "Seguem os dados de instalação:"
echo "---------------------------------------------"
echo "Usuário: ${usuario}"
echo "Grupo(web): ${grupo_web}"
echo "Senha: $senha"
echo "Sistema: ${caminho}"
echo "Config: /etc/agressive/config"
echo "Web: ${webpath}"
echo "---------------------------------------------"
echo

while true; do
  read -p "Deseja continuar? [s/n] " yn
  case $yn in
    [Ss]* ) break;;
    [Nn]* ) echo "Abortando a execução do agreSSive..." && exit 1;;
    *) echo "Por favor, responda sim ou não. ";;
  esac
done

id "${usuario}" 1> /dev/null 2> /dev/null

if [ $? ]; then
  echo
  echo "Criando o usuário: ${usuario}..."
  echo
  useradd -r -m -G $grupo -c "agreSSive User" -s /bin/bash -p $senha $usuario
fi

echo
echo "Criando os arquivos de configuração..."
echo

[ ! -d "$SHOUT_HOME" ] && mkdir -p $SHOUT_HOME
[ ! -d "$TRANS_HOME" ] && mkdir -p $TRANS_HOME
tar xzf "$SHOUT_BIN" -C $SHOUT_HOME
tar xzf "$TRANS_BIN" -C $TRANS_HOME

cat <<EOF > /etc/agressive/config
# agreSSive config
AGRESSIVE_USER=${usuario}
HOMEDIR="/home/\${AGRESSIVE_USER}"
SHOUT_HOME="\${HOMEDIR}/sc"
TRANS_HOME="\${HOMEDIR}/st"
TMUX=\$(which tmux)
TRANS_PATH="\${HOMEDIR}/musicas"
EOF

chown -R ${usuario}:${usuario} /etc/agressive/

#if [ -x $(which apt-get 1> /dev/null) ]; then
#cat <<EOF > /etc/init.d/agressive
cat <<EOF > /tmp/agressive.rc
#!/bin/sh
### BEGIN INIT INFO
# Provides:          agressive
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: startscript agressive
# Description:       startscript for agressive
### END INIT INFO

# Author: Lucas Saliés Brum <lucas@archlinux.com.br>

. /etc/agressive/config

agressive_start()
{
		su \${AGRESSIVE_USER} -c "\${TMUX} new-session -d -s \${AGRESSIVE_USER} \"cd \$SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf\""
		su \${AGRESSIVE_USER} -c "\${TMUX} new-window -d -t \${AGRESSIVE_USER}:2 \"cd \$TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf\""
}

agressive_stop()
{
		su $USER -c "$TMUX kill-session -t $TMUX_SESSION"
		$TMUX kill-session -t $TMUX_SESSION
    pkill -9 sc_serv
    pkill -9 sc_trans
}

case "$1" in
start)
        echo "Iniciando o agreSSive..."
        agressive_start
;;
stop)
        echo "Parando agreSSive..."
        agressive_stop
;;
restart)
        echo "Parando o agreSSive..."
        agressive_stop
        echo "Iniciando o agreSSive..."
        agressive_start
;;
*)
        echo "Uso: $0 {start|stop|restart}"
esac
EOF

#chmod 755 /etc/init.d/agressive

#else

cat <<EOF > /etc/systemd/system/agressive.service
[Unit]
Description=agreSSive Framework
After=network.target

[Service]
#Type=forking
Type=oneshot
ExecStart=/usr/local/bin/agressivectl start
ExecReload=/usr/local/bin/agressivectl restart
ExecStop=/usr/local/bin/agressivectl stop
#Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

#fi

cat <<EOF > /usr/local/bin/agressivectl
#!/bin/bash
#
# Auto Instalador do agreSSive Framework
# Um sistema completo para criação e administração de rádios usando o ShoutCast e sc_trans!
# Por: Lucas Saliés Brum, a.k.a. sistematico <lucas AT archlinux DOT com DOT br>
# Criado em 05/02/2017
# Alterado em 05/02/2017

[ ! -e '/etc/agressive/config' ] && echo "Arquivo de configuração não encontrado. Abortando..." && exit 1

source /etc/agressive/config

do_start()
{
	if [ "\$(whoami)" == "\${AGRESSIVE_USER}" ]; then
		\${TMUX} new-session -d -s \${AGRESSIVE_USER} "cd \$SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf"
		\${TMUX} new-window -d -t \${AGRESSIVE_USER}:2 "cd \$TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf"
	else
		su \${AGRESSIVE_USER} -c "\${TMUX} new-session -d -s \${AGRESSIVE_USER} \"cd \$SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf \""
		su \${AGRESSIVE_USER} -c "\${TMUX} new-window -d -t \${AGRESSIVE_USER}:2 \"cd \$TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf \""
	fi
}

do_stop()
{
	killall -9 sc_serv
	killall -9 sc_trans
	if [ "\$(whoami)" != "\${AGRESSIVE_USER}" ]; then
		su ${AGRESSIVE_USER} -c "\$TMUX kill-session -t \${AGRESSIVE_USER}"
	else
		\$TMUX kill-session -t \${AGRESSIVE_USER}
	fi
  killall -9 sc_serv
  killall -9 sc_trans
}

do_attach()
{
	if [ "\$(whoami)" == "\${AGRESSIVE_USER}" ]; then
		\$TMUX a -t \${AGRESSIVE_USER}
	else
		su \${AGRESSIVE_USER} -c "\$TMUX a -t \${AGRESSIVE_USER}"
	fi
}

do_status()
{
	if [ "\$(whoami)" == "\${AGRESSIVE_USER}" ]; then
		PID=\$(tmux ls | grep \${AGRESSIVE_USER} 1> /dev/null 2> /dev/null)
		if [ ! "\$PID" ]; then
			echo "O agreSSive está rodando."
		else
			echo "O agreSSive não está rodando."
		fi
	else
		PID=\$(su \${AGRESSIVE_USER} -c "tmux ls | grep \${AGRESSIVE_USER} 1> /dev/null 2> /dev/null")
		if [ ! "\$PID" ]; then
			echo "O agreSSive está rodando."
		else
			echo "O agreSSive não está rodando."
		fi
	fi
}

case "\$1" in
start)
        echo "Iniciando o agreSSive..."
        do_start
;;
stop)
        echo "Parando o agreSSive..."
        do_stop
;;
restart)
        echo "Re-iniciando o agreSSive..."
        do_stop
        do_start
;;
attach)
        echo "Attachando ao agreSSive..."
        do_attach
;;
status)
        do_status
;;
*)
        echo $"Uso: \$0 {start|stop|restart|attach|status}"
esac
EOF

chmod 755 /usr/local/bin/agressivectl
chown ${usuario}:${usuario} /usr/local/bin/agressivectl

echo "#!/usr/bin/php ${webpath}/php/engine.php" > ${TRANS_HOME}/playlists/agressive.lst
chmod 777 ${TRANS_HOME}/playlists/agressive.lst
[ ! -d "${TRANS_HOME}/archived/" ] && mkdir -p ${TRANS_HOME}/archived/
[ ! -d "${TRANS_HOME}/priority/archived" ] && mkdir -p ${TRANS_HOME}/priority/archived/

[ ! -d "${webpath}" ] && mkdir -p ${webpath}

cp -r /tmp/agressive/web/* ${webpath}
cp /tmp/agressive/sistema/.tmux.conf ${webpath}

[ ! -d "${webpath}/db" ] && mkdir -p ${webpath}/db
touch ${webpath}/db/agressive.sqlite

chown -R www-data:agressive ${webpath}
chmod 775 ${webpath}/php/engine.php
chmod 777 ${webpath}/db ${webpath}/db/agressive.sqlite
#chmod 664 ${webpath}/php/engine.php
chmod 775 ${webpath}/{conf,php}
chmod 664 ${webpath}/conf/config.php

read -p "Título da Rádio [Padrão: Radio agreSSive] " titulo
read -p "Site da Rádio [Padrão: https://sistematico.github.io/agressive] " site
read -p "Senha da fonte [Padrão: sourcepasswd] " sourcepasswd
read -p "Senha do admin [Padrão: adminpasswd] " adminpasswd
read -p "Gênero [Padrão: Misc] " genero
read -p "IP [Padrão: localhost] " ip
read -p "Porta [Padrão: 8000] " porta
read -p "Bitrate [Padrão: 128000] " bitrate
read -p "mp3 ou aac? [Padrão: aac] " tipo
read -p "Máximo de ouvintes [Padrão: 512] " ouvintes

findip="$(/sbin/ip -o -4 addr list venet0 | awk '{print $4}' | cut -d/ -f1 | tail -n 1)"

titulo=${titulo:-"Radio agreSSive"}
site=${site:-"https://sistematico.github.io/agressive"}
sourcepasswd=${sourcepasswd:-"sourcepasswd"}
adminpasswd=${adminpasswd:-"adminpasswd"}
genero=${genero:-"Misc"}
ip=${ip:-$findip}
porta=${porta:-"8000"}
bitrate=${bitrate:-"128000"}
tipo=${tipo:-"aac"}

if [ "$tipo" == "mp3" ]; then
read -p "Nome de usuário da licença de mp3? [Padrão: nenhum] " lnome
read -p "Key da licença de mp3? [Padrão: nenhuma] " lkey

cat > $mpeglic <<- EOM
unlockkeyname=${lnome}
unlockkeycode=${lkey}
EOM
fi


cat <<EOF > ${SHOUT_HOME}/sc_serv_agressive.conf
;DNAS configuration file
;Build with agreSSive

logfile=logs/agressive.log
adminpassword=${adminpasswd}
streamadminpassword_1=brandnewman83
maxuser=512
password=${sourcepasswd}
requirestreamconfigs=1
publicserver=always
streampassword_1=${sourcepasswd}
streampath_1=/stream
streammaxuser=${adminpasswd}
streamauthhash_1=
EOF

cat <<EOF > ${TRANS_HOME}/sc_trans_agressive.conf
;Transcoder configuration file
;Build with agreSSive

calendarrewrite=0
streamtitle=${titulo}
streamurl=${site}
genre=${genero}
password_1=${sourcepasswd}
endpointname_1=/stream
streamid=1
logfile=logs/sc_trans.log
playlistfile=playlists/agressive.lst
;shuffle=0
outprotocol=3
serverip=${ip}
serverport=${porta}
bitrate=${bitrate}
encoder=${tipo}
${mpeglic}
EOF

[ ! -d "/home/${usuario}/musicas" ] && mkdir /home/${usuario}/musicas

read -p "Copiar arquivo de exemplo para /home/${usuario}/musicas? [S/n] " yn
while true; do
    case $yn in
        [Nn]* ) break;;
        * )
        if [ -f /tmp/agressive/sistema/musicas/* ]; then
          cp -fr /tmp/agressive/sistema/musicas/* /home/${usuario}/musicas/
        fi
        break
        ;;
    esac
done

cp /tmp/agressive/sistema/.tmux.conf /home/${usuario}/
chown -R ${usuario}:${usuario} /etc/agressive/ /home/${usuario}

echo
echo "**********************************************************"
echo "***                                                    ***"
echo "***                INSTALAÇÃO COMPLETA                 ***"
echo "***                                                    ***"
echo "**********************************************************"
echo
echo "Acesse: $(hostname)/agressive/php/install.php para continuar a instalação."
echo
echo "Para iniciar o serviço digite:"
echo "systemctl start agressive"
echo
echo "Para iniciar automaticamente após o reboot digite:"
echo "systemctl enable agressive"
exit 0
