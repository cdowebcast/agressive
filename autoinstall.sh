#!/bin/bash
#
# Auto Instalador do agreSSive Framework
# Um sistema completo para criação e administração de rádios usando o ShoutCast e sc_trans!
#
# Por: Lucas Saliés Brum, a.k.a. sistematico <lucas AT archlinux DOT com DOT br>
# Criado em:    05/02/2017 08:59:53
# Alterado em:  18/09/2018 08:59:59

##############################
########## CONFIGS ###########
##############################
# Internet Check
internet_check=false

##############################
########## VARS ##############
##############################
AGRESSIVE_USER=${usuario}
HOMEDIR="/home/${usuario}"
SHOUT_HOME="${HOMEDIR}/sc"
TRANS_HOME="${HOMEDIR}/st"
TMUX=$(which tmux)

##############################
########## CORES #############
##############################
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

##############################
########## FUNÇÕES ###########
##############################
logo() {
  echo -e ${VERMELHO}
  echo -e '                      ____ ____  _           '
  echo -e '  __ _  __ _ _ __ ___/ ___/ ___|(_)_   _____ '
  echo -e ' / _` |/ _` | '__/ _ \___ \___ \| \ \ / / _ \'
  echo -e '| (_| | (_| | | |  __/___) |__) | |\ V /  __/'
  echo -e ' \__,_|\__, |_|  \___|____/____/|_| \_/ \___|'
  echo -e '       |___/  '
  echo -e ${LIMPA}
}

procura_arquivos() {
  if [ $# -gt 0 ] && [ ! -e $1 ]; then
    echo "O arquivo ${VERMELHO}$1${LIMPA} não foi encontrado. Abortando..." >&2
    exit 1
  fi
}

##############################
########## PROGRAMA ##########
##############################
echo
echo "Bem vindo ao..."
logo

[ "$(id -u)" != "0" ] && echo "Este script deve ser executado apenas como root." 1>&2 && exit 1
#[[ "$(find / -iname which 2> /dev/null)" == "" ]] && echo "which não encontrado. Abortando..." >&2 && exit 1
[ ! $(which tmux) ] && echo "which não encontrado. Abortando..." >&2 && exit 1
[ ! $(which tmux) ] && echo "tmux não encontrado. Abortando..." >&2 && exit 1
[ ! $(which nginx) ] && echo "nginx não encontrado. Abortando..." >&2 && exit 1
[ ! $(which git) ] && echo "git não encontrado. Abortando..." >&2 && exit 1

if [ $internet_check == true ]; then
  ping -q -c1 google.com > /dev/null 2> /dev/null
  if [ $? -ne 0 ]; then
    echo "Sem conexão com a internet, abortando..."
    exit 1
  fi
fi

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
    echo
    echo -e "Sistema operacional encontrado: ${VERMELHO}DEBIAN${LIMPA}/${VERMELHO}UBUNTU${LIMPA}!"
elif [[ -x $(which pacman 2> /dev/null) ]]; then
    sistema="arch"
    #webpath="$(pacman -Qo nginx | grep www | tail -1)/agressive"
    webpath="$(dirname $(pacman -Ql nginx | egrep 'html|www' | tail -n1 | awk '{print $2}'))/agressive"
    echo
    echo -e "Sistema operacional encontrado: ${VERMELHO}ARCH LINUX${LIMPA}!"
elif [[ -x $(which yum 2> /dev/null) ]]; then
    sistema="centos"
    webpath="/var/www/html/agressive"
    echo
    echo -e "Sistema operacional encontrado: ${VERMELHO}CENTOS${LIMPA}!"
else
  echo
  echo "Sistema operacional não identificado. Abortando..."
  exit 1
fi

if [ "$sistema" == "arch" ]; then
  pacman -Q php-sqlite nginx php-fpm 1> /dev/null 2> /dev/null
  if [ $? -ne 0 ]; then
    echo
    echo "Faltam pacotes para a sua distribuição, instalando..."
    pacman -S php-sqlite nginx php-fpm --noconfirm
  fi
fi

echo
echo "Alterando para a pasta /tmp..."

cd /tmp

if [ -d "$AGRESSIVE_TEMP" ]; then
  echo
  read -p "A pasta $AGRESSIVE_TEMP já existe, apagar e baixar uma nova? [s/N] " yn

  if [ "$yn" == [sS] ]; then
    echo
    echo "Apagando a pasta $AGRESSIVE_TEMP..."
    rm -rf $AGRESSIVE_TEMP
    echo
    echo "Clonando o repositório do agreSSive..."
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
    if [ ! -f '$AGRESSIVE_TEMP/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz' ] || [ ! -f '$AGRESSIVE_TEMP/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz' ]; then
      echo
      echo "Binários do Shoutcast e/ou sc_trans não encontrados. Abortando..."
      exit 1
    fi
  fi
else
  echo
  echo "Clonando o repositório do agreSSive..."
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
echo "Entrando na pasta $AGRESSIVE_TEMP..."

[ ! -d $AGRESSIVE_TEMP ] && mkdir $AGRESSIVE_TEMP
cd $AGRESSIVE_TEMP

echo
read -p "Qual será o nome do usuário que vai rodar o agreSSive? [Padrão: agressive]" usuario_raw
usuario_raw=${usuario_raw:-"agressive"}

echo
echo "Sanitizando o nome de usuário..."
# underscores
limpo=${usuario_raw//_/}
# spaces with underscores
limpo=${limpo// /_}
# only alphanumeric or an underscore
limpo=${limpo//[^a-zA-Z0-9_]/}
# lowercase
usuario=`echo -n $limpo | tr A-Z a-z`

if [ -d $(eval echo "~${usuario}") ]; then
  echo
  read -p "Este usuário ou a pasta dele já existe, deseja sobre-escrever? [s/N] " yn
  while true; do
    case $yn in
      [Ss]* ) break;;
      * ) echo && echo "Abortando a execução do agreSSive..." && exit 1;;
    esac
  done
  caminho=$(eval echo ~${usuario})
else
  echo
  read -sp "Senha do usuário e do agreSSive? [Padrão: agressive]" senha_raw
  senha_raw=${senha_raw:-"agressive"}
  senha=$(perl -e 'print crypt($ARGV[0], "senha_raw")' $senha_raw)
  caminho="/home/${usuario}"
fi

AGRESSIVE_USER=${usuario}
HOMEDIR="/home/${usuario}"
SHOUT_HOME="${HOMEDIR}/sc"
TRANS_HOME="${HOMEDIR}/st"
TMUX=$(which tmux)
TEMP_PATH="$AGRESSIVE_TEMP"
#SHOUT_BIN="${TEMP_PATH}/sistema/downloads/sc_serv2_linux_x64_07_31_2011.tar.gz"
SHOUT_BIN="${TEMP_PATH}/sistema/downloads/sc_serv2_linux_x64-latest.tar.gz"
TRANS_BIN="${TEMP_PATH}/sistema/downloads/sc_trans_linux_x64_10_07_2011.tar.gz"

echo
read -p "Qual será a pasta do agreSSive no servidor Web?? [Padrão: ${webpath}] " webp
webp=${webp:-$webpath}
webpath=$webp

usuario_web=$(head -n3 /etc/nginx/nginx.conf 2> /dev/null | grep user | awk '{print $2}' | tr -d ';')
if [ "$usuario_web" == "" ]; then
  usuario_web="www-data"
fi

echo
read -p "Usuário padrão do servidor web [Padrão: ${usuario_web}] " usuario_web

echo
read -p "Grupo padrão do servidor web [Padrão: www-data] " grupo_web
grupo_web=${grupo_web:-"www-data"}

echo
read -p "Caminho onde ficam as músicas [Padrão: ${HOMEDIR}/musicas] " caminho_musicas
caminho_musicas=${caminho_musicas:-"${HOMEDIR}/musicas"}

if [[ ! $(grep $grupo_web /etc/group) ]]; then
  echo
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
echo "Caminho das músicas: ${caminho_musicas}"
echo "---------------------------------------------"

while true; do
  echo
  read -p "Deseja continuar? [s/n] " yn
  case $yn in
    [Ss]* ) break;;
    [Nn]* ) echo && echo "Abortando a execução do agreSSive..." && exit 1;;
    *) echo && echo "Por favor, responda sim ou não. ";;
  esac
done

if [[ ! $(id ${usuario} 2> /dev/null) ]]; then
  echo
  echo "Criando o usuário: ${usuario}..."
  useradd -r -m -G "${grupo_web}" -c "agreSSive User" -s /bin/bash -p "${senha}" "${usuario}"
fi

echo
echo "Criando os arquivos de configuração..."

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
MUSICAS="\${caminho_musicas}"
EOF

cat <<EOF > /etc/systemd/system/agressive.service
[Unit]
Description=agreSSive Framework
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/agressivectl start
ExecReload=/usr/local/bin/agressivectl restart
ExecStop=/usr/local/bin/agressivectl stop

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
	killall -9 sc_serv 2> /dev/null
	killall -9 sc_trans 2> /dev/null
	if [ "\$(whoami)" != "\${AGRESSIVE_USER}" ]; then
		su ${AGRESSIVE_USER} -c "\$TMUX kill-session -t \${AGRESSIVE_USER}" 2> /dev/null
	else
		\$TMUX kill-session -t \${AGRESSIVE_USER} 2> /dev/null
	fi
  killall -9 sc_serv 2> /dev/null
  killall -9 sc_trans 2> /dev/null
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
		tmux ls | grep \${AGRESSIVE_USER} 1> /dev/null 2> /dev/null
		if [ \$? = 0 ]; then
			echo "O agreSSive está rodando."
		else
			echo "O agreSSive não está rodando."
		fi
	else
		su \${AGRESSIVE_USER} -c "tmux ls | grep \${AGRESSIVE_USER}" 1> /dev/null 2> /dev/null
		if [ \$? = 0 ]; then
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

cp -r $AGRESSIVE_TEMP/web/* ${webpath}
cp $AGRESSIVE_TEMP/sistema/.tmux.conf ${webpath}

[ ! -d "${webpath}/db" ] && mkdir -p ${webpath}/db
touch ${webpath}/db/agressive.sqlite

chown -R ${usuario}:${grupo_web} ${webpath}
chmod 775 ${webpath}/php/engine.php
chmod 777 ${webpath}/db ${webpath}/db/agressive.sqlite
chmod 775 ${webpath}/{conf,php}
chmod 664 ${webpath}/conf/config.php

echo
read -p "Título da Rádio [Padrão: Radio agreSSive] " titulo
read -p "Site da Rádio [Padrão: https://sistematico.github.io/agressive] " site
read -p "Senha da fonte [Padrão: sourcepasswd] " sourcepasswd
read -p "Senha do admin [Padrão: adminpasswd] " adminpasswd
read -p "Gênero [Padrão: Misc] " genero
read -p "IP/Domínio [Padrão: localhost] " ip
read -p "Porta [Padrão: 8000] " porta
read -p "Bitrate [Padrão: 128000] " bitrate
read -p "mp3 ou aac? [Padrão: aac] " tipo
read -p "Máximo de ouvintes [Padrão: 512] " ouvintes

#findip="$(/sbin/ip -o -4 addr list venet0 | awk '{print $4}' | cut -d/ -f1 | tail -n 1)"
findip="$(/sbin/ip -o -4 addr list | egrep -v '127.0.0.1' | awk '{print $4}' | cut -d/ -f1 | tail -n 1)"

titulo=${titulo:-"Radio agreSSive"}
site=${site:-"https://sistematico.github.io/agressive"}
sourcepasswd=${sourcepasswd:-"sourcepasswd"}
adminpasswd=${adminpasswd:-"adminpasswd"}
genero=${genero:-"Misc"}
ip=${ip:-$findip}
porta=${porta:-8000}
bitrate=${bitrate:-128000}
tipo=${tipo:-"aac"}
ouvintes=${ouvintes:-512}

if [ "$tipo" == "mp3" ]; then
  echo
  read -p "Nome de usuário da licença de mp3? [Padrão: nenhum] " lnome
  read -p "Key da licença de mp3? [Padrão: nenhuma] " lkey

  if [[ ! -z $lnome && ! -z $lkey ]]; then
    cat > $mpeglic <<- EOM
unlockkeyname=${lnome}
unlockkeycode=${lkey}
EOM
  else
    echo "Licença e/ou nome vazios, revertendo para AAC!"
    tipo="aac"
  fi

fi

cat <<EOF > ${webpath}/conf/config.php
<?php

\$amin = 3;
\$tmin = 5;

\$musicaspath = '${caminho_musicas}';
\$dbpath = dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db';
\$capa_padrao 		= '/img/logotipo.svg';
\$lastfm_api 		= 'CRIE_SUA_API';
\$shoutcast_url	= 'http://${ip}';
\$shoutcast_port	= '${porta}';
\$extensoes = array('mp3');

\$acentos = array(
    'Š'=>'S', 'š'=>'s', 'Ð'=>'Dj','Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A',
    'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I',
    'Ï'=>'I', 'Ñ'=>'N', 'Ń'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U',
    'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss','à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a',
    'å'=>'a', 'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i',
    'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ń'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 'ö'=>'o', 'ø'=>'o', 'ù'=>'u',
    'ú'=>'u', 'û'=>'u', 'ü'=>'u', 'ý'=>'y', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y', 'ƒ'=>'f', '&'=>'e',
    'ă'=>'a', 'î'=>'i', 'â'=>'a', 'ș'=>'s', 'ț'=>'t', 'Ă'=>'A', 'Î'=>'I', 'Â'=>'A', 'Ș'=>'S',
);

if (!empty(\$_SERVER['HTTP_CLIENT_IP'])) {
    \$ip = \$_SERVER['HTTP_CLIENT_IP'];
} elseif (!empty(\$_SERVER['HTTP_X_FORWARDED_FOR'])) {
    \$ip = \$_SERVER['HTTP_X_FORWARDED_FOR'];
} elseif (!empty(\$_SERVER['REMOTE_ADDR'])) {
    \$ip = \$_SERVER['REMOTE_ADDR'];
} else {
  \$ip = "0.0.0.0";
}

function comparaTempo($tempo) {
  \$agora = time();
  \$mins = (\$agora-\$tempo) / 60;
  return floor(abs(\$mins));
}

\$db = new PDO('sqlite:' . dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR . 'db/agressive.sqlite') or die("Impossivel criar BD");
\$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

?>
EOF

cat <<EOF > ${SHOUT_HOME}/sc_serv_agressive.conf
;DNAS configuration file
;Build with agreSSive

w3clog=logs/sc_w3c.log
logfile=logs/agressive.log
adminpassword=${adminpasswd}
streamadminpassword_1=${adminpasswd}
maxuser=${ouvintes}
password=${sourcepasswd}
banfile=agressive.ban
ripfile=agressive.rip
requirestreamconfigs=1
portbase=${porta:-8000}
publicserver=always
streamid=1
streampath=/stream
streammaxuser=${adminpasswd}
streamauthhash=
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
streamid_1=1
logfile=logs/sc_trans.log
playlistfile=playlists/agressive.lst
;shuffle=0
outprotocol_1=3
serverip_1=${ip}
serverport_1=${porta}
bitrate_1=${bitrate}
encoder_1=${tipo}
${mpeglic}
EOF

[ ! -d "/home/${usuario}/musicas" ] && mkdir /home/${usuario}/musicas

echo
read -p "Copiar arquivo de exemplo para /home/${usuario}/musicas? [S/n] " yn
while true; do
    case $yn in
        [Nn]* ) break;;
        * )
        if [ -f $AGRESSIVE_TEMP/sistema/musicas/* ]; then
          cp -fr $AGRESSIVE_TEMP/sistema/musicas/* /home/${usuario}/musicas/
        fi
        break
        ;;
    esac
done

cp $AGRESSIVE_TEMP/sistema/.tmux.conf /home/${usuario}/
chown -R ${usuario}:${usuario} /etc/agressive/ /home/${usuario}

cp /etc/php/php.ini /etc/php/php.ini-$(date +%s)-bkp
sed -i "s|^\(;extension=pdo_sqlite.so\).*|extension=pdo_sqlite.so|" /etc/php/php.ini
sed -i "s|^\(;extension=sqlite3.so\).*|extension=sqlite3.so|" /etc/php/php.ini

logo
echo "**********************************************************"
echo "***                                                    ***"
echo "***                INSTALAÇÃO COMPLETA                 ***"
echo "***                                                    ***"
echo "**********************************************************"
echo
echo -e "Acesse: ${VERMELHO}http://$(hostname)/agressive/php/install.php${LIMPA} para continuar a instalação."
echo
echo "Para iniciar o serviço digite:"
echo -e "${VERMELHO}systemctl start agressive${LIMPA}"
echo
echo "Para iniciar automaticamente após o reboot digite:"
echo -e "${VERMELHO}systemctl enable agressive${LIMPA}"
exit 0
