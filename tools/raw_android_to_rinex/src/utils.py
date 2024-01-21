#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: utils.py
# ---------------------------------------------------------------------------
# Copyright  : 2023 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Utilities functions.
#
# ---------------------------------------------------------------------------
# Reference  : [1] I.Romero, RINEX The Receiver Independent Exchange Format
#                  Version 3.05, IGS/RTCM RINEX WG Chair ESA/ESOC/Navigation
#                  Support Office, December 01, 2020
#              [2] European Global Navigation Satellite System (GSA).
#                  Using GNSS Raw Measurements on Android Devices. 
#                  Publications Office of the European Union, Luxembourg.
#                  2016. doi: 10.2878/449581.
#              [3] Raw GNSS Measurements (2023) 
#                  https://developer.android.com/develop/sensors-and-location/sensors/gnss
#                  Accessed 23 Nobember 2023
#
# History    : 2023/11/23 1.0  First version
#
# ---------------------------------------------------------------------------
"""

# Import libraries
import os
import logging
from pathlib import Path
from typing import Any

# Constants
PWD = os.getcwd()
OUT_FOLDER = f"{PWD}/rinex"
TYPES = {
    "AccumulatedDeltaRangeState": int,
    "ConstellationType": int,
    "MultipathIndicator": int,
    "State": int,
    "Svid": int,
    "CodeType": str,
}


def check_log_file(log_file: Path) -> bool:
    """
    Check if file exists

    :param  log_file:       Log File

    :return exists          True if File exists, else False
    """
    # Variables
    exists = False

    # Check if file exists
    if log_file.is_file():
        exists = True
    else:
        logging.error("File %s not found!", str(log_file))

    return exists


def convert_value(key: str, value: str) -> Any:
    """
    Convert value to its specific type

    :param  value:          Value to convert

    :return result          Converted value
    """
    # Check type
    try:
        if key in TYPES:
            return TYPES[key](value)
        return float(value)
    except ValueError:
        return "Invalid"


def check_value(value: Any, key: str) -> bool:
    """
    Check if value is valid

    :param  value:          Value to check
    :param  key:            Name of the value

    :return is_valid        True/False if value is valid/invalid
    """
    # Check value
    if value == "Invalid":
        logging.warning("Wrong %s %s.", key, str(value))
        return False

    return True


def print_rinex3(header: str, obs: str, filename: str) -> None:
    """
    Write RINEX 3 File

    :param  header:         RINEX 3 Header
    :param  obs:            RINEX 3 Observations
    :param  filename:       File to write

    :return None
    """
    # Ensure the folder exists
    if not os.path.exists(OUT_FOLDER):
        os.makedirs(OUT_FOLDER)

    # Full Path
    file_path = os.path.join(OUT_FOLDER, filename)

    # Write text
    with open(file_path, "w", encoding="UTF-8") as file:
        file.write(header)
        file.write(obs)
