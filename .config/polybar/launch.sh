#!/usr/bin/env bash

export MONITOR=$(polybar --list-monitors | sed s/:.*// | tail -1)
polybar panel 2>&1 > /tmp/polybar.log
