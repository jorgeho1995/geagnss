#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: readers.py
# ---------------------------------------------------------------------------
# Copyright  : 2023 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Functions for reading data logged.
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
#              2024/10/27 1.1  Include BDS III Signals (B1C, B2A, B2B)
#
# ---------------------------------------------------------------------------
"""

# Import libraries
import os
import logging
from pathlib import Path
from typing import Union, Any, List, Dict
from utils import convert_value, check_value
from rinex_obs import freq_code, sat_system_letter

# Constants
GEA_INFO = "GEA"
GNSSLOGGER_INFO = "Version"
INIT_HEADER_LINE = "#"
RAW_LINE = "Raw"


def get_observable_types(raw_data: List[Any]) -> Dict[str, Any]:
    """
    Process Raw Data and extract types of observables

    :param  raw_data:       Raw Data

    :return obs_dict        Observation Dictionary
    """
    # Variables
    obs_dict: Dict[str, Any] = {}

    # Loop through all observables
    # pylint: disable=unused-variable
    for i, raw in enumerate(raw_data):
        # State
        state = raw["State"]
        if not check_value(state, "State"):
            continue

        # Svid
        svid = raw["Svid"]
        if not check_value(svid, "Svid"):
            continue

        # Constellation Type
        cons_type = raw["ConstellationType"]
        if not check_value(cons_type, "ConstellationType"):
            continue

        carrier_freq_hz = raw["CarrierFrequencyHz"]
        if not check_value(carrier_freq_hz, "CarrierFrequencyHz"):
            continue

        # Get Satellite System
        sat_sys = sat_system_letter(cons_type, svid)

        # Get Obs Code
        fr_code = freq_code(carrier_freq_hz, cons_type, state)

        # Create array per System
        if sat_sys not in obs_dict:
            obs_dict[sat_sys] = []

        # Add obserbable if not in the list
        fr_list = obs_dict[sat_sys]
        if fr_code not in fr_list:
            obs_dict[sat_sys].append(fr_code)

    # Sort
    for key, value in obs_dict.items():
        fr_list = sorted(value)
        obs_dict[key] = [m + o for o in fr_list for m in ["C", "L", "D", "S"]]

    return obs_dict


def read_log_file(log_file_path: Union[str, Path]) -> Dict[str, Any]:
    """
    Read and store Raw GNSS data from log file

    :param  log_file_path:  Input log file to format

    :return log_dict        Dictionary with all Raw Data logged
    """
    # Variables
    log_dict: Dict[str, Any] = {}
    log_dict["app_info"] = ""
    log_dict["app_station"] = ""
    log_dict["app_version"] = ""
    raw_header: List[str] = []
    raw_data: List[Any] = []

    # Check if file exists
    if os.path.exists(log_file_path):
        # Read File
        with open(log_file_path, "r", encoding="UTF-8") as file:
            lines = file.readlines()
            for line in lines:
                content = line.split("\n")[0]
                # Read header and observation if header is available
                if INIT_HEADER_LINE in content:
                    if RAW_LINE in content:
                        raw_header = content.split(",")
                    elif GEA_INFO in content:
                        log_dict["app_info"] = "GEA"
                        log_dict["app_station"] = "GNSS00GEA"
                        log_dict["app_version"] = content.split(":")[1][1:]
                        log_dict["app_observer"] = "GEA"
                    elif GNSSLOGGER_INFO in content:
                        manufacturer = content.split("Model: ")[1]
                        log_dict["app_info"] = f"{manufacturer}"
                        log_dict["app_station"] = "GNSS00LOG"
                        log_dict["app_version"] = content.split(":")[1].split(" ")[1]
                        log_dict["app_observer"] = "GNSSLogger"
                elif raw_header and RAW_LINE in content:
                    data = content.split(",")
                    if len(raw_header) == len(data):
                        raw = {}
                        for i in range(1, len(raw_header)):
                            result = convert_value(raw_header[i], data[i])
                            if result is None:
                                raw[raw_header[i]] = data[i]
                            else:
                                raw[raw_header[i]] = result
                        raw_data.append(raw)
                    else:
                        logging.warning("Wrong observation %s", str(content))

    # Create dict to retun
    log_dict["obs_dict"] = get_observable_types(raw_data)
    log_dict["raw_header"] = raw_header
    log_dict["raw"] = raw_data

    return log_dict
