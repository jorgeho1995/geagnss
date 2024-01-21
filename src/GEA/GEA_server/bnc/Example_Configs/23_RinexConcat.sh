#!/bin/bash

../bnc -nw -conf /dev/null \
       -key reqcAction Edit/Concatenate \
       -key reqcObsFile Input/brux350a\*.12o \
       -key reqcRnxVersion 3 \
       -key reqcSampling 30 \
       -key reqcStartDateTime 1967-11-02T00:00:00 \
       -key reqcEndDateTime 2099-01-01T00:00:00 \
       -key reqcNewMarkerName BRUX_MARKER \
       -key reqcOutLogFile Output/RinexConcat.log \
       -key reqcOutObsFile Output/brux350a.12o

