#!/bin/bash
current_os=$1
current_user=$2
current_user_group=$3
current_machine="$(uname -m)"

#.bashrc
#export INTEGRA_S_VIDEO_USE_SUDO_FOR_SCRIPTS=1

if [ ! -z "$INTEGRA_S_VIDEO_USE_SUDO_FOR_SCRIPTS" ]; then
  use_sudo="sudo "
else
  use_sudo=""

  if [ -z $current_user ]; then
    current_user="$(whoami)"
  fi
  if [ -z $current_user_group ]; then
    current_user_group="$(id -g --name)"
  fi
  if [ -z $current_os ]; then
    current_os="$(uname -s)"
  fi
  ID_UTILITY="id"
  if [ $current_os = "SunOS" ]
  then
    ID_UTILITY="/usr/xpg4/bin/id"
  fi
  if [ ! `$ID_UTILITY -u` = "0" ]
  then
    if [ $current_os = "SunOS" ]
    then
      echo "Solaris: Run as root !"
    elif [ $current_os = "Linux" ]
    then
      if [ `grep -i debian /etc/issue | wc -l` -gt "0" ]
      then
        current_os="Debian"
        su --preserve-environment -c "bash $0 $current_os $current_user $current_user_group"
      elif [ `grep -i ubuntu /etc/issue | wc -l` -gt "0" ]
      then
        current_os="Ubuntu"
        sudo bash $0 $current_os $current_user $current_user_group
      else
        echo "Run as root !"
      fi
    elif [ $current_os = "Darwin" ]
    then
      echo "Mac X: Run as root !"
    elif [ $current_os = "HP-UX" ]
    then
      echo "HP-UX: Run as root !"
    else
      echo "UnknownOS: Run as root !"
    fi
    exit
  fi
fi


echo "== video services start begin"

systemctl_exists="n"
if [ -x "$(command -v systemctl)" ] ; then systemctl_exists="y"; fi

service_start() {
  service_name=$1
  if [ $systemctl_exists = "y" ]
  then
    $use_sudo systemctl stop $service_name
    $use_sudo systemctl start $service_name
  else
    $use_sudo /etc/init.d/$service_name stop
    $use_sudo /etc/init.d/$service_name start
  fi
}

service_start keyguard 
service_start nginxv7
service_start wconfig
if [ -e /etc/init.d/waxis ]; then service_start waxis; fi
if [ -e /etc/init.d/wusers ]; then service_start wusers; fi
service_start videosrv7
service_start stability

echo "== video services start end"
echo -e "\nPress <ENTER> to continue"
