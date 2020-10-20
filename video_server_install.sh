#!/bin/bash
old_dir="`pwd`/`basename "$0"`"
old_dir=`dirname "$old_dir"`
cd "`dirname "$0"`"
script_dir="`pwd`/`basename "$0"`"
script_dir=`dirname "$script_dir"`

CURRENT_USER="$(whoami)"
echo "Enter user name:"
read CURRENT_USER

answer="$(whoami)"
echo "Use core dump(y/N)?"
read answer

coredumpval=false
if [ "$answer" = "y" ]
then
	coredumpval=true
elif [ "$answer" = "yes" ]
then
	coredumpval=true
fi

echo "Use parent(restarter) and child(main) processes(Y/n)?"
read answer

autorecoveryval=true
if [ "$answer" = "n" ]
then
	autorecoveryval=false
elif [ "$answer" = "no" ]
then
	autorecoveryval=false
fi

"$script_dir/video-server-7.0" reg --name videosrv7 --display_name "Video Server 7.0" --user "$CURRENT_USER" --pidfile true --autorecovery "$autorecoveryval" --coredump "$coredumpval"

cd "$old_dir"
read
