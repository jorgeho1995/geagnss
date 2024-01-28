#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: utils.py
# ---------------------------------------------------------------------------
# Copyright  : 2024 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Utilities functions.
#
# ---------------------------------------------------------------------------
# Reference  : [1] European Global Navigation Satellite System (GSA).
#                  Using GNSS Raw Measurements on Android Devices. 
#                  Publications Office of the European Union, Luxembourg.
#                  2016. doi: 10.2878/449581.
#              [2] Raw GNSS Measurements (2023) 
#                  https://developer.android.com/develop/sensors-and-location/sensors/gnss
#                  Accessed 23 Nobember 2023
#
# History    : 2024/01/28 1.0  First version
#
# ---------------------------------------------------------------------------
"""

# Import libraries
import logging
from pathlib import Path
from typing import Any, Dict
import numpy as np

# Constants
TYPES = {
    "AccumulatedDeltaRangeState": int,
    "ConstellationType": int,
    "MultipathIndicator": int,
    "State": int,
    "Svid": int,
    "CodeType": str,
}


def check_rt_file(rt_file: Path) -> bool:
    """
    Check if file exists

    :param  rt_file:        Log File

    :return exists          True if File exists, else False
    """
    # Variables
    exists = False

    # Check if file exists
    if rt_file.is_file():
        exists = True
    else:
        logging.error("File %s not found!", str(rt_file))

    return exists


def decode_timest(nmea_msg: str) -> Dict[str, Any]:
    """
    Decode TIMEST message and add to Dict.

    :param  nmea_msg     :  NMEA TIMEST message

    :return timest       :  Dict where decoded msg is stored
    """
    # Split NMEA values from msg
    msg = nmea_msg.split(",")

    # Add new message to Dict
    timest: Dict[str, Any] = {}
    timest["nmeaType"] = msg[0]
    timest["numMsgs"] = int(msg[1])
    timest["posMsg"] = int(msg[2])

    # Get date
    day = msg[3][0:2]
    month = msg[3][2:4]
    year = msg[3][4:]
    timest["date"] = f"{day}-{month}-20{year}"

    # Get time
    hour = msg[4][0:2]
    mins = msg[4][2:4]
    secs = msg[4][4:]
    timest["time"] = f"{hour}:{mins}:{secs}"

    # Split Values
    last_values = msg[5].split("*")
    timest["source"] = last_values[0]
    timest["checksum"] = last_values[1]

    return timest


def generate_stats(latency_dict: Dict[str, Any]) -> str:
    """
    Generate Statistics

    :param  latency_dict:   Dictionary with Latency Time Series

    :return stats_str       String with all the statistics
    """
    # Variables
    latency_time = latency_dict["latencyTime"]
    serverproc_time = latency_dict["serverTimeProc"]

    # Statistics
    mean_lat = np.mean(latency_time)
    max_lat = np.max(latency_time)
    min_lat = np.min(latency_time)
    std_lat = np.std(latency_time)
    median_lat = np.median(latency_time)

    mean_ser = np.mean(serverproc_time)
    max_ser = np.max(serverproc_time)
    min_ser = np.min(serverproc_time)
    std_ser = np.std(serverproc_time)
    median_ser = np.median(serverproc_time)

    # Get stats table
    table = f"""\n \
        +------------+------------+------------+\n \
        | Statistics | Latency (s)| Server (s) |\n \
        +------------+------------+------------+\n \
        | Mean       |   {mean_lat:.6f} |   {mean_ser:.6f} |\n \
        | Max        |   {max_lat:.6f} |   {max_ser:.6f} |\n \
        | Min        |   {min_lat:.6f} |   {min_ser:.6f} |\n \
        | Std        |   {std_lat:.6f} |   {std_ser:.6f} |\n \
        | Median     |   {median_lat:.6f} |   {median_ser:.6f} |\n \
        +------------+------------+------------+"""

    return table
