#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: rinex_header.py
# ---------------------------------------------------------------------------
# Copyright  : 2023 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: RINEX Header generation
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
import datetime
from typing import List, Dict


def rnx3_header_ver_type(version: float, type_obs: str) -> str:
    """
    Header line RINEX VERSION / TYPE

    :param  version:        RINEX Version
    :param  type_obs:       Obs Type

    :return head_line       Header Line
    """
    # Variables
    end_line = "RINEX VERSION / TYPE"
    blanck = " "

    # Line
    head_line = (
        f"{version:9.2f}{blanck:11s}{type_obs}{blanck:4s}M{blanck:19s}{end_line}\n"
    )

    return head_line


def rnx3_header_pgm_runby_date(pgm: str, runby: str) -> str:
    """
    Header line PGM / RUN BY / DATE

    :param  pgm:            Program
    :param  runby:          Run By / Agency

    :return head_line       Header Line
    """
    # Variables
    end_line = "PGM / RUN BY / DATE"
    date = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Line
    head_line = f"{pgm:20s}{runby:20s}{date:20s}{end_line}\n"

    return head_line


def rnx3_header_markername(markername: str) -> str:
    """
    Header line MARKER NAME

    :param  markername:     Maker Name

    :return head_line       Header Line
    """
    # Variables
    end_line = "MARKER NAME"

    # Line
    head_line = f"{markername:60s}{end_line}\n"

    return head_line


def rnx3_header_markernumber(markernumber: str) -> str:
    """
    Header line MARKER NUMBER

    :param  markernumber:   Maker Number

    :return head_line       Header Line
    """
    # Variables
    end_line = "MARKER NUMBER"

    # Line
    head_line = f"{markernumber:60s}{end_line}\n"

    return head_line


def rnx3_header_markertype(markertype: str) -> str:
    """
    Header line MARKER TYPE

    :param  markertype:     Maker Type

    :return head_line       Header Line
    """
    # Variables
    end_line = "MARKER TYPE"

    # Line
    head_line = f"{markertype:60s}{end_line}\n"

    return head_line


def rnx3_header_observer_agency(observer: str, agency: str) -> str:
    """
    Header line OBSERVER / AGENCY

    :param  observer:       Observer
    :param  agency:         Agency

    :return head_line       Header Line
    """
    # Variables
    end_line = "OBSERVER / AGENCY"

    # Line
    head_line = f"{observer:20s}{agency:40s}{end_line}\n"

    return head_line


def rnx3_header_rec_type_version(rec: str, rec_type: str, version: str) -> str:
    """
    Header line REC # / TYPE / VERS

    :param  rec:            Receiver
    :param  rec_type:       Receiver Model
    :param  version:        Receiver Version

    :return head_line       Header Line
    """
    # Variables
    end_line = "REC # / TYPE / VERS"

    # Line
    head_line = f"{rec:20s}{rec_type:20s}{version:20s}{end_line}\n"

    return head_line


def rnx3_header_antenna_type(antenna: str, ant_type: str) -> str:
    """
    Header line ANT # / TYPE

    :param  antenna:        Antenna
    :param  ant_type:       Antenna Model

    :return head_line       Header Line
    """
    # Variables
    end_line = "ANT # / TYPE"

    # Line
    head_line = f"{antenna:20s}{ant_type:40s}{end_line}\n"

    return head_line


def rnx3_header_antenna_pos(pos_list: List[float]) -> str:
    """
    Header line APPROX POSITION XYZ

    :param  pos_list:       Position List

    :return head_line       Header Line
    """
    # Variables
    end_line = "APPROX POSITION XYZ"
    blanck = " "

    # Line
    head_line = f"{pos_list[0]:14.4f}{pos_list[1]:14.4f}{pos_list[2]:14.4f}{blanck:18s}{end_line}\n"

    return head_line


def rnx3_header_antenna_hen(hen_list: List[float]) -> str:
    """
    Header line ANTENNA: DELTA H/E/N

    :param  hen_list:       HEN List

    :return head_line       Header Line
    """
    # Variables
    end_line = "ANTENNA: DELTA H/E/N"
    blanck = " "

    # Line
    head_line = f"{hen_list[0]:14.4f}{hen_list[1]:14.4f}{hen_list[2]:14.4f}{blanck:18s}{end_line}\n"

    return head_line


def rnx3_header_sys_obstype(obs_dict: Dict[str, List[str]]) -> str:
    """
    Header line SYS / # / OBS TYPES

    :param  obs_dict:       Observation Dictionary

    :return head_line       Header Line
    """
    # Variables
    end_line = "SYS / # / OBS TYPES"
    head_line = ""

    # Iter per Satellite System
    for sat_sys in obs_dict:
        obs_sat_sys = obs_dict[sat_sys]
        obs_per_line = [obs_sat_sys[i : i + 13] for i in range(0, len(obs_sat_sys), 13)]
        for i, val in enumerate(obs_per_line):
            line = f"{sat_sys}  {len(obs_sat_sys):3d}" if i == 0 else "      "
            for obs in val:
                line += f" {obs:3s}"
            head_line += f"{line:60s}{end_line}\n"

    return head_line


def rnx3_header_time_first_epoch(epoch: datetime.datetime) -> str:
    """
    Header line TIME OF FIRST OBS

    :param  epoch:          First Epoch

    :return head_line       Header Line
    """
    # Variables
    end_line = "TIME OF FIRST OBS"

    # Line
    date = f'  {epoch.strftime("%Y    %m    %d    %H    %M    %S.")}'
    milli = f"{int(epoch.microsecond):06d}     GPS"
    time = f"{date}{milli}"
    head_line = f"{time:60s}{end_line}\n"

    return head_line


def rnx3_header_end() -> str:
    """
    Header line END OF HEADER

    :return head_line       Header Line
    """
    # Variables
    end_line = "END OF HEADER"
    blanck = " "

    # Line
    head_line = f"{blanck:60s}{end_line}\n"

    return head_line


# pylint: disable=too-many-arguments
# pylint: disable=too-many-locals
def create_header(
    pgm: str,
    runby: str,
    markername: str,
    markernumber: str,
    markertype: str,
    observer: str,
    agency: str,
    rec: str,
    rec_type: str,
    version: str,
    antenna: str,
    ant_type: str,
    pos_list: List[float],
    hen_list: List[float],
    obs_dict: Dict[str, List[str]],
    epoch: datetime.datetime,
) -> str:
    """
    Header line TIME OF FIRST OBS

    :param  pgm:            Program
    :param  runby:          Run By / Agency
    :param  markername:     Maker Name
    :param  markernumber:   Maker Number
    :param  markertype:     Maker Type
    :param  observer:       Observer
    :param  agency:         Agency
    :param  rec:            Receiver
    :param  rec_type:       Receiver Model
    :param  version:        Receiver Version
    :param  antenna:        Antenna
    :param  ant_type:       Antenna Model
    :param  pos_list:       Position List
    :param  hen_list:       HEN List
    :param  obs_dict:       Observation Dictionary
    :param  epoch:          First Epoch

    :return header          Complete Header
    """
    # Variables
    header = rnx3_header_ver_type(3.05, "OBSERVATION DATA")
    header += rnx3_header_pgm_runby_date(pgm, runby)
    header += rnx3_header_markername(markername)
    header += rnx3_header_markernumber(markernumber)
    header += rnx3_header_markertype(markertype)
    header += rnx3_header_observer_agency(observer, agency)
    header += rnx3_header_rec_type_version(rec, rec_type, version)
    header += rnx3_header_antenna_type(antenna, ant_type)
    header += rnx3_header_antenna_pos(pos_list)
    header += rnx3_header_antenna_hen(hen_list)
    header += rnx3_header_sys_obstype(obs_dict)
    header += rnx3_header_time_first_epoch(epoch)
    header += rnx3_header_end()

    return header
