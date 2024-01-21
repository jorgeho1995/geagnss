#!/bin/bash

../bnc -nw -conf /dev/null \
       -key mountPoints "//Example:Configs@igs-ip.net:2101/CUT000AUS0 RTCM_3.2 AUS -32.00 115.89 no 1;//Example:Configs@igs-ip.net:2101/FFMJ00DEU0 RTCM_3.1 DEU 50.09 8.66 no 1" \
       -key logFile Output/RinexObs.log \
       -key rnxPath Output \
       -key rnxIntr "15 min" \
       -key rnxSkel SKL \
       -key rnxSampl 0 \
       -key rnxV3 2 &

psID=`echo $!`
sleep 30
kill $psID

