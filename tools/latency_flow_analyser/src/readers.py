#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: readers.py
# ---------------------------------------------------------------------------
# Copyright  : 2024 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Functions for reading data logged.
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
import os
import logging
from pathlib import Path
from typing import Union, Any, List, Dict
from utils import decode_timest

# Constants
GEA_INFO = "GEA"
INIT_HEADER_LINE = "#"
TIMEST_LINE = "$TIMEST"
NUM_VALUES_TIMEST = 6


def read_gea_rt_file(rt_file_path: Union[str, Path]) -> Dict[str, Any]:
    """
    Read and store GNSS data from GEA RT log file

    :param  rt_file_path:   Input file

    :return rt_dict         Dictionary with all RT data logged
    """
    # Variables
    rt_dict: Dict[str, Any] = {}
    rt_dict["app_info"] = ""
    rt_dict["app_version"] = ""
    timest_data: List[Any] = []

    # Check if file exists
    if os.path.exists(rt_file_path):
        # Read File
        with open(rt_file_path, "r", encoding="UTF-8") as file:
            lines = file.readlines()
            for line in lines:
                content = line.split("\n")[0]
                # Read header and observation if header is available
                if INIT_HEADER_LINE in content and GEA_INFO in content:
                    rt_dict["app_info"] = "GEA"
                    rt_dict["app_version"] = content.split(":")[1][1:]
                elif TIMEST_LINE in content:
                    # NMEA message example: $TIMEST,2,1,270124,101931.687,A*62
                    data = content.split(",")
                    if len(data) == NUM_VALUES_TIMEST:
                        timest = decode_timest(content)
                        timest_data.append(timest)
                    else:
                        logging.warning("Wrong time stamp message %s", str(content))

    # Create dict to retun
    rt_dict["timest"] = timest_data

    return rt_dict
