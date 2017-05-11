#!/bin/bash

USERNAME="steam" # This user *MUST* exist on the system.
EXILE_DIR="/home/${USERNAME}/servers/exile" # Change to your path...
NAME="INSTANCE_NAME_NO_SPACES" # You can use any name here, your server, or clan...
CONFIGFOLDER="${EXILE_DIR}/${NAME}"
CONFIG="${NAME}/config.cfg" # Remember to move config files from @exileserver/*.cfg to YOUR_INSTANCE_NAME/!
CFG="${NAME}/basic.cfg" # Remember to move config files from @exileserver/*.cfg to YOUR_INSTANCE_NAME/!
LOG_DIR="${CONFIGFOLDER}/logs"
PORT=2302
PIDFILE="${CONFIGFOLDER}/${PORT}.pid"
if [ -f ${PIDFILE} ]; then
	RUNNING=1
	PID=$(cat ${PIDFILE} > /dev/null)
else
	RUNNING=0
fi
SERVICE="arma3server"
MODS="@exile"
SERVERMOD="@exileserver"
#CPU_COUNT=2

OPTIONS="-port=${PORT} -pid=${PIDFILE} -name=${NAME} -profiles=${NAME} -cfg=${CFG} -config=${CONFIG} -mod=${MODS} -servermod=${SERVERMOD} -nopause -nosound -nosplash -autoinit"
TMUX_SESSION="exile" # You can use any name here.

#=======================================================================
# CONFIG END
#=======================================================================

TMUX=$(which tmux)

[ ! -x "$TMUX" ] && echo "tmux não encontrado!" >&2 && exit 1

if [ ! -d "$LOG_DIR" ]; then
    echo "${LOG_DIR} não encontrado. Criando..."
    mkdir -p $LOG_DIR
fi

agressive_start() {
    if [ ! -f $EXILE_DIR/$SERVICE ]
    then
        echo "$SERVICE not found! Stopping..."
        sleep 1
        exit
    else
        if  [ ${RUNNING} -eq 1 ];
        then
            echo "$SERVICE is already running!"
        else
            echo "Setting Permissions..."
            #chmod -R 0755 $EXILE_DIR
            chown -R $USERNAME:$USERNAME /home/$USERNAME
            echo "Starting $SERVICE..."
            cd $EXILE_DIR
            if [ "${2}" == "-silent" ]; then
                su ${USERNAME} -c "${TMUX} new-session -d -s ${TMUX_SESSION} \"./${SERVICE} ${OPTIONS} > ${LOG_DIR}/exile.log 2> ${LOG_DIR}/errors.log\""
            else
                su ${USERNAME} -c "${TMUX} new-session -d -s ${TMUX_SESSION} \"./${SERVICE} ${OPTIONS} 2> ${LOG_DIR}/errors.log | tee ${LOG_DIR}/exile.log\""
            fi
            echo "Searching Process ${SERVICE}..."
            sleep 8
            if pgrep -u $USERNAME -f $SERVICE > /dev/null
            then
                echo "$SERVICE is now running."
				RUNNING=1
            else
                echo "Error! Could not start $SERVICE!"
				RUNNING=0
            fi
        fi
    fi
}

agressive_stop() {
    if [ ${RUNNING} -eq 1 ];
    then
        echo "Stopping ${SERVICE}..."
        su $USERNAME -c "$TMUX kill-session -t $TMUX_SESSION"
        $TMUX kill-session -t $TMUX_SESSION
        killall -9 $SERVICE
    else
        echo "$SERVICE is stopped."
    fi

    if [ -f ${PIDFILE} ]; then
        rm -f ${PIDFILE}
    fi
}

agressive_status() {
    if [ -f ${PIDFILE} ]; then
        PID=$(cat ${PIDFILE})
        echo "O agreSSive está rodando (PID=${PID})..."
    else
        echo "O agreSSive não está rodando..."
        exit 0
    fi
}

case "$1" in
    start)
        agressive_start
    ;;

    stop)
        agressive_stop
    ;;

    restart)
        agressive_stop
        agressive_start
    ;;

    status)
        agressive_status
    ;;

    attach)
        su $USERNAME -c "$TMUX at -t $TMUX_SESSION"
    ;;

    *)
        echo "$0 (start|stop|restart|status|attach)"
        exit 1
    ;;
esac

exit 0
