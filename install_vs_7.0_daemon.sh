#!/bin/bash
OSPL="$(uname -s)"
ID_UTILITY="id"
cd "`dirname "$0"`"
if [ "$?" = "0" ]
then
  INSTALL_DIR="`pwd`/`basename "$0"`"
fi
INSTALL_DIR=`dirname "$INSTALL_DIR"`
if [ $OSPL = "SunOS" ]
then
	ID_UTILITY="/usr/xpg4/bin/id"
	OS=solaris
fi
existing="false"
if [ ! `$ID_UTILITY -u` = "0" ]
then
	echo "Please start script by root user"
	exit
fi
echo "Please enter daemon user name:"
read CURRENT_USER
while [ "$CURRENT_USER" = "" ]
do      
	echo "Please enter daemon user name:"
	read CURRENT_USER
done
#echo "$CURRENT_USER" > "/home/.vuser7.txt"
chmod -R 777 "/home/.vuser7.txt"
exec 6<&0                                 #связать дискриптор 6 со стандартным вводом
cut -d : -f 1 /etc/passwd > users_list    #
exec 0<users_list                         #stdin заменяется файлом user_list
while read line
do 
 if [ "$line" = "$CURRENT_USER" ]
 then
   existing="true"
 fi
done
exec 0<&6 6<&-                        #Восстанавливается stdin из дескр. #6, где он был предварительно сохранен,
						#+ и дескр. #6 закрывается ( 6<&- ) освобождая его для других процессов.
rm -f "./users_list"
if [ "$existing" = "false" ]
then
  userdel -r "$CURRENT_USER"                                                             # удаление пользователя
  groupdel  "$CURRENT_USER"                                                             # удаление группы
  addgroup --system "$CURRENT_USER"                                                      # добавление группы
  adduser --quiet --system --disabled-login --ingroup "$CURRENT_USER" "$CURRENT_USER"    # добавление пользователя
fi
chmod -R 777 "$INSTALL_DIR"
if [ -e "$INSTALL_DIR/video-server-7.0" ]
then
	"$INSTALL_DIR/video-server-7.0" unreg --name videosrv7
	"$INSTALL_DIR/video-server-7.0" reg --name videosrv7 --display_name "Video Server 7.0" --user "$CURRENT_USER" --pidfile true
fi
echo "Video Server 7.0 is successfully installed"
