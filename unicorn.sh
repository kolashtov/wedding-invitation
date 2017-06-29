#!/bin/bash
if [ -f shared/config/.production ]; then
 echo "This is production server. On production you must run 'rvmsudo god (restart|start|stop) unicorn'. Note, this operation takes some time, about 1 min." && exit 1
fi
[ -f /etc/profile.d/rvm.sh ] && source /etc/profile.d/rvm.sh
RAILS_ENV="development"
function stop() {
	echo -n "Stopping unicorn..."
	ret=0
	if [ -f shared/unicorn/pids/unicorn.pid ] && [ -e /proc/$(cat shared/unicorn/pids/unicorn.pid) ]; then
		kill `cat shared/unicorn/pids/unicorn.pid`;
		ret=$?
	fi
	if [[ "$ret" != "0" ]]; then
		echo "failed!"
		exit 1;
	else
		rm -f shared/unicorn/pids/unicorn.pid
		echo "done."
	fi
}

function start() {
  RAILS_ENV=$1 || "development"
  prestart $RAILS_ENV
	echo -n "Starting unicorn in $RAILS_ENV mode..."
	bundle exec unicorn -c config/unicorn.rb -E $RAILS_ENV -D
	if [ -f shared/unicorn/pids/unicorn.pid ] && [ -e /proc/$(cat shared/unicorn/pids/unicorn.pid) ]; then
		echo "done."
	else
		echo "failed!"
		exit 1
	fi
}

function prestart() {
  RAILS_ENV=$1 || "development"
	rm log/*log
  touch log/$RAILS_ENV.log
  if [[ "$RAILS_ENV" == "development" ]]; then
    rm -rf tmp/*
  fi
	mkdir -p shared/unicorn/pids/
	chmod 777 shared/unicorn/ -R
}

function help() {
	echo "Usage: "
	echo "$1 [-h] [-E] restart|start|stop "
	echo "Options: "
	echo "-E RAILS_ENV -- set environment, ex '-E developement'"
	echo "-h|--help print this help"

}
while getopts ":E:h" opt; do
  case $opt in
     h)
      	help
      	exit 1
      	;;
     E)
      	RAILS_ENV=$OPTARG
	shift 2
      	;;
    \?)
	help
      	exit 1
      ;;
    :)
        echo "Option -$OPTARG requires an argument." >&2
        exit 1
      ;;
  esac
done
COMMAND=$1
if [[ "x$COMMAND" == "x" ]]; then
	help
	exit 1;
fi

case $COMMAND in
  restart)
  	stop
	start $RAILS_ENV
        exit 1
        ;;
  stop)
	stop
	exit 1
        ;;
  start)
        start $RAILS_ENV
        exit 1
      ;;
esac
