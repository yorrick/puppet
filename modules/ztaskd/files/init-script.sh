#!/bin/bash
### BEGIN INIT INFO
# Provides:          ztaskd
# Required-Start:    $local_fs $remote_fs $network
# Required-Stop:     $local_fs $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/stop ztaskd server instance(s)
# Description:       This script manages ztaskd server instance(s).
### END INIT INFO

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="ztaskd"
NAME="ztaskd"
VIRTUALENV="/home/webapp/virtualenvs/home_automation/bin/activate"
DJANGO_MANAGE="/home/webapp/apps/home_automation/manage.py"
LOGFILE_DIR="/var/log/ztask"
[ -d "$LOGFILE_DIR" ] || { echo "no such directory: '$LOGFILE_DIR'"; exit 1; }
LOGFILE="$LOGFILE_DIR/ztask.log"
DAEMON="/usr/local/bin/ztaskd"
DAEMON_ARGS=" --logfile \"$LOGFILE\" --noreload"
SCRIPTNAME="/etc/init.d/${NAME}"
PIDFILE=/var/run/$NAME.pid
UMASK=022
ZTASKD_USER="webapp"

# Exit if the virtualenv is not installed
[ -r "$VIRTUALENV" ] || exit 0
# Exit if the virtualenv is not installed
[ -x "$DJANGO_MANAGE" ] || exit 0

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
   # Return
   #   0 if daemon has been started
   #   1 if daemon was already running
   #   2 if daemon could not be started

   start-stop-daemon --start --background --quiet --pidfile $PIDFILE --make-pidfile --exec "$DAEMON" \
      --chuid $ZTASKD_USER --user $ZTASKD_USER --umask $UMASK -- "$DAEMON_ARGS"

   case "$?" in
       "0")
           echo "Started ztaskd deamon"; return 0;
       ;;
       "1")
           echo "Already started"; return 1;
       ;;
       "2")
           echo "Could not start ztaskd deamon"; return 2;
       ;;
   esac
}

#
# Function that stops the daemon/service
#
do_stop()
{
   # Return
   #   0 if daemon has been stopped
   #   1 if daemon was already stopped
   #   2 if daemon could not be stopped
   #   other if a failure occurred

   start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --user $ZTASKD_USER --pidfile $PIDFILE
   RETVAL="$?"
   [ "$RETVAL" = "2" ] && return 2

   rm -f $PIDFILE
   RETVAL="$?"
   [ "$RETVAL" = "0" ] && (echo "Stopped ztaskd deamon"; return 0;) || (echo "Ztaskd deamon was already stopped"; return 1;)
}

case "$1" in
  start)
   [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
   do_start
   case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
   esac
   ;;
  stop)
   [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
   do_stop
   case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
   esac
   ;;
  restart|force-reload)
   log_daemon_msg "Restarting $DESC" "$NAME"
   do_stop
   case "$?" in
     0|1)
      do_start
      case "$?" in
         0) log_end_msg 0 ;;
         1) log_end_msg 1 ;; # Old process is still running
         *) log_end_msg 1 ;; # Failed to start
      esac
      ;;
     *)
        # Failed to stop
      log_end_msg 1
      ;;
   esac
   ;;
  *)
   echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
   exit 3
   ;;
esac

: