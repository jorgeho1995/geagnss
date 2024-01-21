#!/bin/bash

/usr/bin/Xvfb :1 -screen 0 1280x1024x8 2>/dev/null &
psID=`echo $!`

../bnc -nw -conf /dev/null -display :1 \
       -key reqcAction Analyze \
       -key reqcObsFile Input/cut0350a.12o \
       -key reqcNavFile Input/brdc350a.12p \
       -key reqcSkyPlotSignals "C:2&7 E:1&5 G:1&2 J:1&2 R:1&2 S:1&5" \
       -key reqcOutLogFile Output/RinexQc.log \
       -key reqcPlotDir Output

kill $psID

