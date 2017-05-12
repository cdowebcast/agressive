#!/bin/bash

# Author: Lucas Saliés Brum <lucas@archlinux.com.br>

[ -f "/etc/agressive/config" ] &&	. /etc/agressive/config || echo "Arquivo de configuração não encontrado. Abortando..." && exit 1

if [ $(whoami) = "$USER" ]; then
	COMANDO=
else
	COMANDO="su ${AGRESSIVE_USER} -c"
fi

do_start()
{
	if [ $(whoami) = "$USER" ]; then
		${TMUX} new-session -d -s ${AGRESSIVE_USER} "cd $SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf 2> /dev/null 1> /dev/null &"
		${TMUX} -d -t ${AGRESSIVE_USER}:2 "cd $TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf 2> /dev/null 1> /dev/null &"
	else
		su ${AGRESSIVE_USER} -c "${TMUX} new-session -d -s ${AGRESSIVE_USER} \"cd $SHOUT_HOME; ./sc_serv ./sc_serv_agressive.conf 2> /dev/null 1> /dev/null &\""
		su ${AGRESSIVE_USER} -c "${TMUX} -d -t ${AGRESSIVE_USER}:2 \"cd $TRANS_HOME; ./sc_trans ./sc_trans_agressive.conf 2> /dev/null 1> /dev/null &\""
	fi
}

do_stop()
{
		su $USER -c "$TMUX kill-session -t ${AGRESSIVE_USER}"
		$TMUX kill-session -t ${AGRESSIVE_USER}
    pkill -9 sc_serv
    pkill -9 sc_trans
}

case "$1" in
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
*)
        echo "Uso: $0 {start|stop|restart}"
esac
