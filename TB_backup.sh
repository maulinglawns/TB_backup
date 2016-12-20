#!/bin/bash

# Script for backing up all of Thunderbird's settings and mail:
# the 'Profiles' directory
# For macOS/MacOS X.
#
# Exit codes:
# 0 - success
# 1 - nothing to backup (no 'Profiles' directory found)

#--------- Variables ---------# 
TB="THUNDERBIRD-BACKUP"
# Run script as current user
TB_USER=$(whoami)
# Path to Thunderbird 
BACKUP_LOCATION=/Users/$TB_USER/Library/Thunderbird
# The directory to backup
BACKUP_SOURCE=/Profiles
TMP_LOCATION=$HOME/Documents

#--------- Functions ---------# 
### Completely unnecessary geek-text at beginning ###
function welcome {
    printf "\t"
    tput bold
  
    for ((i=0; i<${#TB}; i++)); do
        printf ${TB:$i:1}
        sleep 0.09
    done
  
    tput sgr0
  
    sleep 1
}

### Check if Thunderbird is running ###
function stop_tbird {
    ps aux | grep Thunderbird.app | grep -v grep &> /dev/null
  
    if [[ $? == 0 ]]; then
        echo "$(tput setaf 1)Varning!$(tput sgr0)"
        echo "Var vänlig avsluta Thunderbird innan du startar backupen."
        echo "Tryck sedan [ENTER]."
        read
        stop_tbird
    fi
}

### Exits with error 1 if there is no directory to backup ###
function error_check {
    if [[ ! -d $BACKUP_LOCATION$BACKUP_SOURCE ]]; then
        echo "Hoppsan! Det finns inget att ta backup på."
        echo "Något är galet. Avslutar..."
        sleep 1
        exit 1
    fi
}

### Shows tar progress ###
function tar_progress {
    cd $BACKUP_LOCATION
  
    #Get size of source directory
    DIR_SIZE=$(du -h $BACKUP_LOCATION$BACKUP_SOURCE | tail -1 \
                | awk '{ print $1 }')
  
    while [[ -d $TMP_LOCATION/bktemp123 ]]; do
        if [[ -f Thunderbird_$(date +%x).tar ]]; then
          #Get size of tar-archive
          TAR_SIZE=$(du -h Thunderbird*tar 2> /dev/null | tail -1 \
                    | awk '{ print $1 }')
        fi
        
        echo -ne "$(tput setaf 2)Jobbar:\t\t$(tput bold)\
          $TAR_SIZE av $DIR_SIZE $(tput sgr0)\r" #Overwrite line with -ne & \r
        sleep 0.09
    done
}

### Creates the actual tar-archive ###
function makebackup {
    cd $TMP_LOCATION
  
    if [[ ! -d bktemp123 ]]; then
        mkdir bktemp123
    fi
  
      cd $BACKUP_LOCATION
      tar_progress &
      sleep 0.8
      tar -cf Thunderbird_$(date +%x).tar ${BACKUP_SOURCE//\//}
      sleep 1.2
      mv *.tar $HOME/Desktop
      rmdir $TMP_LOCATION/bktemp123
}

#--------- Program start ---------# 
clear

welcome

echo
echo "Detta är ett script för att ta en backup av Thunderbird,
alla inställningsfiler och alla mejlkorgar sparas."
echo

stop_tbird

error_check

while true; do
    echo "Välj ett alternativ nedan:"
    cat << choices
    1. Starta scriptet
    0. Avsluta
choices
    read -s -n 1 UserChoice

    case $UserChoice in
    1)
        echo "Okej. Scriptet körs."
        sleep 1
        makebackup
        printf "\nKlar. Nu finns en fil på skrivbordet som heter:
        \"Thunderbird_$(date +%x).tar\". Kopiera den till ditt USB-minne."
        printf "\n"
        sleep 1.3
        echo "När det är gjort, avmontera USB-minnet."
        sleep 1.3
        echo
        echo "Avslutar. Du kan stänga det här fönstret när du vill."
        break
        ;;
    0)
        echo "Avslutar..."
        sleep 1
        exit 0
        ;;

    *)
        echo "Ogiltigt val. Försök igen."
        echo
        sleep 1
        ;;
        esac

done

exit 0
