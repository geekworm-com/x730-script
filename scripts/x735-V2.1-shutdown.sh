#!/bin/bash

#X735 Shutdown through software

GPIOCHIP=gpiochip0

BUTTON_PIN=18

#Set internal biases and pull the pins
gpioset -B pull-up gpiochip0 $BUTTON_PIN=1

SLEEP=${1:-4}

re=^[0-9.]+
if ! [[ $SLEEP =~ $re ]] ; then
   echo "error: sleep time not a number" >&2; exit 1
fi

# Detect all (S)ATA devices
DEVICES=()

PART=$(cat /proc/partitions)

for x in {a..z}
do
   #SATA
   if [[ $PART == *"sd$x"* ]]
   then
      DEVICES+=("sd$x")
   fi
   #ATA
   if [[ $PART == *"hd$x"* ]]
   then
      DEVICES+=("hd$x")
   fi
done

printf "Shutting down all SATA devices... ($DEVICES)"
for d in $DEVICES
do
   sudo hdparm -Y /dev/$d &
   /bin/sleep 0.1
   printf "Device $d off \n"
done

echo "X735 Shutting down..."
/bin/sleep $SLEEP

#restore GPIO 18
gpioset -B pull-down gpiochip0 $BUTTON_PIN=0