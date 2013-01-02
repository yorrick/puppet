#!/bin/bash

# you need to create the directories for PIDFILE and LOGFILE and give them the necessary permissions
PIDFILE_DIR="/var/run/ztask"
[ -d "$PIDFILE_DIR" ] || { echo "no such directory: '$PIDFILE_DIR'"; exit 1; }
PIDFILE="$PIDFILE_DIR/ztask.pid"
LOGFILE_DIR="/var/log/ztask"
[ -d "$LOGFILE_DIR" ] || { echo "no such directory: '$LOGFILE_DIR'"; exit 1; }
LOGFILE="$LOGFILE_DIR/ztask.log"
LOCKDIR="$PIDFILE_DIR/ztaskd.lock"
WORKDIR=`dirname "$0"`
cd "$WORKDIR"

get_lock() {
 # usage:
 # get_lock lockdir
 # function adapted from http://wiki.bash-hackers.org/howto/mutex

 lockdir="$1"
 pidfile="$lockdir/get_lock.pid"

 # exit codes and text for them - additional features nobody needs :-)
 ENO_SUCCESS=0; ETXT[0]="ENO_SUCCESS"
 ENO_GENERAL=1; ETXT[1]="ENO_GENERAL"
 ENO_LOCKFAIL=2; ETXT[2]="ENO_LOCKFAIL"
 ENO_RECVSIG=3; ETXT[3]="ENO_RECVSIG"

 if mkdir "${lockdir}" &>/dev/null; then
  echo "$$" >"${pidfile}"
  # the following handler will exit the script on receiving these signals
  trap 'echo "[get_lock] Killed by a signal." >&2
  exit ${ENO_RECVSIG}' 1 2 3 15
 else
  # lock failed, now check if the other PID is alive
  OTHERPID="$(cat "${pidfile}")"
  # if cat wasn't able to read the file anymore, another instance probably is
  # about to remove the lock -- exit, we're *still* locked
  #  Thanks to Grzegorz Wierzowiecki for pointing this race condition out on
  #  http://wiki.grzegorz.wierzowiecki.pl/code:mutex-in-bash
  if [ $? != 0 ]; then
   echo "lock failed, PID ${OTHERPID} is active" >&2
   exit ${ENO_LOCKFAIL}
  fi

  if ! kill -0 $OTHERPID &>/dev/null; then
   # lock is stale, remove it and restart
   echo "removing stale lock of nonexistant PID ${OTHERPID}" >&2
   rm -rf "${lockdir}"
   # restart the locking
   get_lock "${lockdir}"
  else
   # lock is valid and OTHERPID is active - exit, we're locked!
   echo "lock failed, PID ${OTHERPID} is active" >&2
   exit ${ENO_LOCKFAIL}
  fi
 fi
}

cp_start()
{
 ./manage.py ztaskd --logfile "$LOGFILE" --pidfile "$PIDFILE" --noreload --daemonize
}

cp_stop()
{
 ./manage.py ztaskd --pidfile "$PIDFILE" --stop
}

cp_restart()
{
 get_lock "${LOCKDIR}"
 cp_stop >/dev/null
 cp_start
 rm -rf "${LOCKDIR}"
}

case "$1" in
 "start")
  cp_start
 ;;
 "stop")
  cp_stop
 ;;
 "restart")
  cp_restart
 ;;
 *)
  "$@"
 ;;
esac

