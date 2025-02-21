#!/usr/bin/env bash

export MONITOR=$(polybar --list-monitors | grep primary | sed s/:.*//)
polybar panel 2>&1 > /tmp/polybar.log
