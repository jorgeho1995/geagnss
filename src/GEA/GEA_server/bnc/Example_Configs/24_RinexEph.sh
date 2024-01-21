#!/bin/bash

../bnc -nw -conf /dev/null \
       -key mountPoints "//Example:Configs@products.igs-ip.net:2101/BCEP00BKG0 RTCM_3 DEU 50.09 8.66 no 1" \
       -key ephPath Output \
       -key logFile Output/RinexEph.log \
       -key ephIntr "1 hour" \
       -key ephV3 2 &

psID=`echo $!`
sleep 10
kill $psID

