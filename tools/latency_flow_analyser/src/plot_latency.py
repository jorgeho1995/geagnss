#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: plot_latency.py
# ---------------------------------------------------------------------------
# Copyright  : 2024 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: Functions for plotting data logged.
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
from datetime import datetime
from typing import Any, Dict, List
from plotly import graph_objects as go

# Constants
SOURCE_APP = "A"
SOURCE_SERVER = "S"
PWD = os.getcwd()
OUT_FOLDER = f"{PWD}/plots"


def get_timediff(timest_list_s: List[Any]) -> Dict[str, Any]:
    """
    Get Time Difference

    :param  timest_list_s:  List with all TIMEST by source

    :return timediff_dict   Dictionary with time difference
    """
    # Variables
    timediff_dict: Dict[str, Any] = {}
    epochs: List[Any] = []
    timediff: List[Any] = []

    # Loop all TIMEST messages
    prev_pos = 0
    prev_date = ""
    for i, value in enumerate(timest_list_s):  # pylint: disable=unused-variable
        num_msgs = value["numMsgs"]
        curr_pos = value["posMsg"]
        if curr_pos == num_msgs and prev_pos == 1 and curr_pos != prev_pos:
            curr_date = f'{value["date"]} {value["time"]}'
            prev_datetime = datetime.strptime(prev_date, "%d-%m-%Y %H:%M:%S.%f")
            curr_datetime = datetime.strptime(curr_date, "%d-%m-%Y %H:%M:%S.%f")
            latency = curr_datetime - prev_datetime
            if latency.total_seconds() < 1.0:
                timediff.append(latency.total_seconds())
                epochs.append(prev_datetime)
            prev_pos = 0
            prev_date = ""
        elif curr_pos == 1 and prev_pos == 0:
            prev_date = f'{value["date"]} {value["time"]}'
            prev_pos = curr_pos

    # Create dict to retun
    timediff_dict["epochs"] = epochs
    timediff_dict["timeDiff"] = timediff

    return timediff_dict


def get_latency_time_series(timest_dict: Dict[str, Any]) -> Dict[str, Any]:
    """
    Geat Latency Time Series

    :param  timest_dict:    Dictionary with all TIMEST separated by source

    :return latency_dict    Dictionary with Latency Time Series
    """
    # Variables
    latency_dict: Dict[str, Any] = {}

    # Create dict to retun
    timediff_app = get_timediff(timest_dict["sourceApp"])
    timediff_server = get_timediff(timest_dict["sourceServer"])
    latency_dict["epochsApp"] = timediff_app["epochs"]
    latency_dict["epochsServer"] = timediff_server["epochs"]
    latency_dict["latencyTime"] = timediff_app["timeDiff"]
    latency_dict["serverTimeProc"] = timediff_server["timeDiff"]

    return latency_dict


def get_timest_msgs_per_source(timest_msgs: List[Any]) -> Dict[str, Any]:
    """
    Get TIMEST messages per source (A: App, S: Server)

    :param  timest_msgs:    List with all TIMEST data logged

    :return timest_dict     Dictionary with all TIMEST separated by source
    """
    # Variables
    timest_dict: Dict[str, Any] = {}
    timest_app: List[Any] = []
    timest_server: List[Any] = []

    # Loop to classify the messages
    for i, value in enumerate(timest_msgs):  # pylint: disable=unused-variable
        # Source
        source = value["source"]

        # Check source and store
        if source in SOURCE_APP:
            timest_app.append(value)
        elif source in SOURCE_SERVER:
            timest_server.append(value)

    # Create dict to retun
    timest_dict["sourceApp"] = timest_app
    timest_dict["sourceServer"] = timest_server

    return timest_dict


def generate_plots(rt_dict: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process messages and generate plots

    :param  rt_dict:        Dictionary with all RT data logged

    :return latency_dict    Dictionary with Latency Time Series
    """
    # Variables
    timest_msgs = rt_dict["timest"]

    # Process messages
    timest_dict = get_timest_msgs_per_source(timest_msgs)
    latency_dict = get_latency_time_series(timest_dict)

    # Generate plots
    fig = go.Figure()
    fig.add_trace(
        go.Scatter(
            x=latency_dict["epochsApp"], y=latency_dict["latencyTime"], name="Latency"
        )
    )
    fig.add_trace(
        go.Scatter(
            x=latency_dict["epochsServer"],
            y=latency_dict["serverTimeProc"],
            name="Server Proc Time",
        )
    )
    fig.update_layout(
        title="Latency (obs<->sol) vs Server Processing Time",
        xaxis_title="Time (UTC)",
        yaxis_title="Time Diff (seconds)",
    )
    fig.show()

    # Ensure the folder exists
    if not os.path.exists(OUT_FOLDER):
        os.makedirs(OUT_FOLDER)

    # Write plot
    fig.write_image(f"{OUT_FOLDER}/latency.png", scale=2.1934758155230596)

    # Return
    return latency_dict
