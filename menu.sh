#!/bin/bash

cancel=1
escape=255
HEIGHT=0
WIDTH=0
export DIALOGRC="./.dialogrc"

__enterpasswd() {
    unset mypass1
    local exit_status
    exit_status=0
    mypass1=""

    mypass1="$(dialog --output-fd 1 --cancel-label "Back" --backtitle "MyApp Setup" --title "Admin password" --clear --insecure "$@" --passwordbox "enter password:" 16 51)"
 
     exit_status=$?

     case $exit_status in
     0) return 0 ;;
     $cancel) return 1 ;;
	 $escape) clear; exit 1 ;;
	 esac
}

__validpasswd() {
    local exit_status
    exit_status=0

    if [[ "$mypass1" == "slob" ]]; then
        msgbox "Admin password" "slob not allowed!"

     exit_status=$?
     case $exit_status in
     0)
       return 1
       ;;
     1) return 1 ;;
	 $escape)
     clear
     exit 1
	   ;;
	 esac
    fi
}

__confirmpasswd() {
    unset mypass2
    local exit_status
    exit_status=0
    mypass2="$(dialog --output-fd 1 --cancel-label "Back" --backtitle "MyApp Setup" --title "Admin password" --clear --insecure "$@" --passwordbox "confirm password:" 16 51)"

     exit_status=$?

     case $exit_status in
     0)
       return 0
       ;;
     $cancel)
	   return 1
	   ;;
	 $escape)
     clear
     exit 1
	   ;;
	 esac
}

__equalpasswd() {
    local exit_status
    exit_status=0

    if [[ "$mypass1" != "$mypass2" ]]; then
        msgbox "Admin password" "passwords not the same!"

     exit_status=$?
     case $exit_status in
     0)
       return 1
       ;;
	 $escape)
     clear
     exit 1
	   ;;
	 esac
    fi
}

msgbox() {
   dialog --title "$1" \
    --backtitle "MyApp Setup" \
    --no-collapse \
    --ok-label "OK" \
    --msgbox "$2" 0 0
}

while true; do

 exec 3>&1

 select=$(dialog \
   --backtitle "MyApp Setup" \
   --title "Configuration" \
   --clear \
   --cancel-label "Exit" \
   --menu "Choose an option." $HEIGHT $WIDTH 4 \
   "Listen address" "change server listen address" \
   "Admin password" "change admin user password" \
   2>&1 1>&3)

 exit_status=$?

 exec 3>&-

 case $exit_status in
   $cancel)
     clear 
     exit
     ;;
   $escape)
     clear
     exit 1
     ;;
 esac

  case $select in
      "Listen address")
          dialog --backtitle "MyApp Setup" --title "Listen address" --clear "$@" \
          --radiolist "change server listen address:" 20 61 5 \
          "192.168.0.45" "It's an apple." off \
          "Localhost" "Cats like fish." off \
          "All" "No, that's not my dog." ON 2>slobwashere
          exit_status1=$?
     case $exit_status1 in
     $cancel)
	   clear
	   exit
	   ;;
	 $escape)
	   ;;
	 esac
     ;;

   "Admin password")
   while :; do
        __enterpasswd
        if [[ $? -ne 0 ]]; then
            break
        fi

        __validpasswd
        if [[ $? -ne 0 ]]; then
            continue
        fi

        __confirmpasswd
        if [[ $? -ne 0 ]]; then
            continue
        fi

        __equalpasswd
        if [[ $? -ne 0 ]]; then
            continue
        else
            # Set password.
            builtin echo "$mypass1:$mypass2" >mypass.$$
            break
        fi

   done

    ;;
   esac

done
