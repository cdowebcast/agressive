#! /bin/sh
### BEGIN INIT INFO
# Provides:          agressive
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: startscript agressive
# Description:       startscript for agressive
#										 Put in /etc/init.d/agressive with chmod 755
### END INIT INFO

# Author: Lucas Saliés Brum <lucas@archlinux.com.br>

# Carrega configurações do arquivo config.cfg, se ele existir...
CONFIG="${HOMEDIR}/config.cfg"
[ -f $CONFIG ] &&	. $CONFIG || echo "Arquivo de configuração não encontrado." && exit 1

# Checagem
[ ! -x "$TMUX" ] && echo "tmux não encontrado!" >&2 && exit 1

if [ $(id -u $NAME 2> /dev/null) ]; then
	echo "Usuário encontrado."
	exit 0
else
	echo "Usuário não encontrado."
	exit 0	
fi

do_start()
{
		su ${USER} -c "${TMUX} new-session -d -s ${NAME} \"cd $SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf 2> /dev/null 1> /dev/null &\""
		su ${USER} -c "${TMUX} -d -s ${NAME}:1 \"cd $TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf 2> /dev/null 1> /dev/null &\""
}

do_stop()
{
		su $USER -c "$TMUX kill-session -t $TMUX_SESSION"
		$TMUX kill-session -t $TMUX_SESSION
    pkill -9 sc_serv
    pkill -9 sc_trans
}

case "$1" in
start)
        echo "Iniciando o ${DESC}..."
        do_start
;;
stop)
        echo "Parando o ${NAME}..."
        do_stop
;;
restart)
        echo "Parando o ${NAME}..."
        do_stop
        echo "Iniciando o ${NAME}..."
        do_start
;;
*)
        echo "Uso: $NAME {start|stop|restart}"
esac
