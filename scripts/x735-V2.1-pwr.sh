#!/bin/bash

#x735-V2.1 Reboot or shutdown on latching switch signal

GPIOCHIP=gpiochip0

SHUTDOWN_PIN=4
BOOT_PIN=17

REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600

#Set internal biases and pull the pins
gpioset -B pull-down gpiochip0 $SHUTDOWN_PIN=0
gpioset -B pull-up gpiochip0 $BOOT_PIN=1

printf "X735 Shutting down..."

shutdownSignal=$(gpiomon -F e gpiochip0 $SHUTDOWN_PIN)

pulseStart=$(date +%s%N | cut -b1-13)


while [ 1 ]; do
  shutdownSignal=$(gpiomon -F e gpiochip0 $SHUTDOWN_PIN)
  if [ $shutdownSignal != 0 ]; then
    pulseStart=$(date +%s%N | cut -b1-13)
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 1
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
        echo "X735 Shutting down", $SHUTDOWN_PIN, ", halting Rpi ..."
        sudo poweroff
        exit
      fi
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
    done
    if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then 
      echo "X735 Rebooting", $SHUTDOWN_PIN, ", recycling Rpi ..."
      sudo reboot
      exit
    fi
  fi
done