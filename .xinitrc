#!/bin/sh
# Disable access control for the current user.
#xhost +SI:localuser:$USER

# Make Java applications aware this is a non-reparenting window manager.
export _JAVA_AWT_WM_NONREPARENTING=1
#USER_EMACS_DIRECTORY=$HOME/.config/emacs

# Set default cursor.
#xsetroot -cursor_name left_ptr

# Set keyboard repeat rate.
#xset r rate 200 60

test -f ~/.bashrc && source ~/.bashrc
#test -f ~/.Xresources && xrdb ~/.Xresources

#xhost +

dconf dump /net/launchpad/plank/docks/ > ~/.config/plank/docks.ini

#(
#sleep 20
#autorandr --change
#nm-applet &
#insync start &
#blueman-applet &
#udiskie --tray &
#indicator-sound-switcher &
#radiotray-ng &
#caffeine &
#pasystray &
#gxkb &
#copyq &
#redshift-gtk &
#keepassxc &
#trayclock &
#cbatticon &
#mictray &
#meteo-qt &
##jetbrains-toolbox &
#picom & # composite manager, plank prefers it
#) &


exec $WM $ARG1 $ARG2 $ARG3 $ARG4 $ARG5 $ARG6
#
