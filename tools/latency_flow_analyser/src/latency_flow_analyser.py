#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: latency_flow_analyser.py
# ---------------------------------------------------------------------------
# Copyright  : 2024 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Get latency plots from GEA output
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
import argparse
from pathlib import Path
import sys
import logging
from typing import Sequence, Type

from utils import check_rt_file, generate_stats
from readers import read_gea_rt_file
from plot_latency import generate_plots


class ScriptArgs(argparse.Namespace):  # pylint: disable=too-few-public-methods
    """
    Input Console Arguments.
    """

    rt_file: str


def parse_argv(args: Sequence[str]) -> Type[ScriptArgs]:
    """
    Parses input console arguments

    :param  args:           Console Arguments

    :return parsed_args     Parsed arguments
    """
    # Help Message
    parser = argparse.ArgumentParser(
        description="Get latency plots from GEA output\n" "\n",
        epilog="Example: latency_flow_analyser" " $(ABS_PATH)/rt_gea_log.txt",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "rt_file", type=str, help="path to real time log file from GEA output."
    )

    return parser.parse_args(args, namespace=ScriptArgs)


def main() -> None:
    """
    Main function that reads log file and generate
    plots.

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
    rt_file = Path(parsed_args.rt_file)

    # Check if file exists
    if not check_rt_file(rt_file):
        sys.exit()

    # Read RT Log File
    logging.info("Reading file...")
    rt_dict = read_gea_rt_file(rt_file)

    # Generate plots
    logging.info("Generating plots...")
    latency_dict = generate_plots(rt_dict)

    # Generate Statistics
    logging.info("Generating statistics...")
    table_stats = generate_stats(latency_dict)
    logging.info("Statistics: %s", table_stats)
    logging.info("Done!")


if __name__ == "__main__":
    # Run Software
    main()
