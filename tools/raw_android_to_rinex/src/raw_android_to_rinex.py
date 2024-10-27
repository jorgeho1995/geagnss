#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: raw_android_to_rinex.py
# ---------------------------------------------------------------------------
# Copyright  : 2023 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Android to RINEX Converter
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
import argparse
from pathlib import Path
import sys
import logging
from typing import Sequence, Type

from utils import check_log_file, print_rinex3
from readers import read_log_file
from rinex_header import create_header
from rinex_obs import create_obs


class ScriptArgs(argparse.Namespace):  # pylint: disable=too-few-public-methods
    """
    Input Console Arguments.
    """

    log_file: str


def parse_argv(args: Sequence[str]) -> Type[ScriptArgs]:
    """
    Parses input console arguments

    :param  args:           Console Arguments

    :return parsed_args     Parsed arguments
    """
    # Help Message
    parser = argparse.ArgumentParser(
        description="Convert logs with Raw GNSS Data from Android Smartphones"
        "to RINEX.\n"
        "\n",
        epilog="Example: raw_android_to_rinex" " $(ABS_PATH)/gnsss_log.txt",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "log_file", type=str, help="path to log file with Raw GNSS data."
    )

    return parser.parse_args(args, namespace=ScriptArgs)


def main() -> None:
    """
    Main function that reads log file with Raw GNSS data
    and converts into RINEX.

    """
    # Logger
    logging.basicConfig(
        format="%(asctime)s %(levelname)s: %(message)s",
        datefmt="%H:%M:%S",
        level=logging.INFO,
    )
    logging.info("Starting!")

    # Arguments
    parsed_args = parse_argv(sys.argv[1:])
    log_file = Path(parsed_args.log_file)

    # Check if file exists
    if not check_log_file(log_file):
        sys.exit()

    # Read Log File
    logging.info("Reading file...")
    log_dict = read_log_file(log_file)

    # Create Obs
    logging.info("Formatting Observations in RINEX 3 Format...")
    obs = create_obs(log_dict["raw"], log_dict["obs_dict"])

    # Check data
    if "firstEpoch" not in obs:
        logging.error("No valid data in %s file", str(log_file))
        sys.exit()

    # Create Header
    logging.info("Formatting RINEX 3 Header...")
    header = create_header(
        "Android RINEX 1.1",
        "UPV",
        log_dict["app_station"],
        "",
        "",
        log_dict["app_observer"],
        "",
        "",
        log_dict["app_info"],
        log_dict["app_version"],
        "NONE",
        "NONE",
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
        log_dict["obs_dict"],
        obs["firstEpoch"],
    )

    # Print in file
    logging.info("Creating RINEX 3 File...")
    date_str = obs["firstEpoch"].strftime("%Y%m%d%H%M")
    filename = f'{log_dict["app_station"]}_R_{date_str}_00U_01S_MO.rnx'
    print_rinex3(header, obs["obsString"], filename)
    logging.info("Done!")


if __name__ == "__main__":
    # Run Software
    main()
