#!/usr/bin/env python3
"""
# ---------------------------------------------------------------------------
# File: rinex_obs.py
# ---------------------------------------------------------------------------
# Copyright  : 2023 by J.Hernandez, All rights reserved.
# Author     : J.Hernandez
# Description: RINEX Observations generation
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
import logging
import datetime
import math
from typing import Any, List, Dict
from utils import check_value

# Constants
SYSTEM_ORDER = ["G", "R", "E", "C", "Q", "I", "S"]
GPS = 1
SBAS = 2
GLONASS = 3
QZSS = 4
BEIDOU = 5
GALILEO = 6
IRNSS = 7
UNKNOWN = 0
SAT_SYSTEM_LETTER = {
    GPS: "G",
    SBAS: "S",
    GLONASS: "R",
    QZSS: "J",
    BEIDOU: "C",
    GALILEO: "E",
    IRNSS: "I",
    UNKNOWN: "X",
}

S_GAL_E1B_PAGE_SYNC = int(0x00001000)
S_GAL_E1C_2ND_CODE_LOCK = int(0x00000800)

BDST_TO_GPST = 14
DAYSEC = 86400
GPS_WEEKSECS = 604800
NS_TO_S = 1.0e-9
SPEED_OF_LIGHT = 299792458.0


def band(carrier_freq: float) -> int:
    """
    Get Frequency band

    :param  carrier_freq:   Carrier Frequency

    :return bn              Frequency Band
    """
    # Variables
    try:
        freq_int = round(carrier_freq / 10.23e6)
    except ValueError:
        logging.warning("Wrong frequency %s.", str(carrier_freq))
        return -1

    bn = -1
    # QZSS L1, GPS L1, GAL E1, and GLO L1
    if freq_int >= 154:
        bn = 1
    # QZSS L5, GPS L5, GAL E5, BDS B2A
    elif freq_int == 115:
        bn = 5
    # BDS B2B
    elif freq_int == 118:
        bn = 7
    # BDS B3I
    elif freq_int == 118:
        bn = 7
    # BDS B1I
    elif freq_int == 153:
        bn = 2
    else:
        logging.warning("Wrong frequency %s.", str(carrier_freq))

    return bn


def rnx_band_letter(cons_type: int, bn: int, state: int) -> str:
    """
    Get Frequency Code

    :param  cons_type:      Constellation type
    :param  bn:             Band
    :param  state:          State

    :return band_letter     Band letter
    """
    # Variables
    band_letter = "C"

    # Check E1C, E1B in Galileo
    if bn == 1 and cons_type == GALILEO:
        st_code_lock = state & S_GAL_E1C_2ND_CODE_LOCK
        st_page_sync = state & S_GAL_E1B_PAGE_SYNC
        if st_code_lock == 0 and st_page_sync != 0:
            band_letter = "B"

    # E5, L5
    if bn == 5:
        band_letter = "Q"

    # BDS cases
    if cons_type == BEIDOU:
        if bn == 1: # BDS B1C
            band_letter = "D"
        elif bn == 2: # BDS B1I
            band_letter = "I"
        elif bn == 5: # BDS B2A
            band_letter = "D"
        elif bn == 7: # BDS B2B
            band_letter = "D"
        elif bn == 6: # BDS B3I
            band_letter = "I"

    return band_letter


def freq_code(carrier_freq: float, cons_type: int, state: int) -> str:
    """
    Get Observation Code

    :param  carrier_freq:   Carrier Frequency
    :param  cons_type:      Constellation type
    :param  state:          State

    :return obs_code        Observation letter
    """
    # Get band
    bn = band(carrier_freq)
    if bn == -1:
        return "Invalid"

    # Get Rinex value for band
    obs_code = rnx_band_letter(cons_type, bn, state)

    return f"{bn}{obs_code}"


def sat_system_letter(cons_type: int, svid: int) -> str:
    """
    Get Satellite System letter

    :param  cons_type:      Constellation type
    :param  svid:           Satellite Id

    :return sat_sys         Satellite System letter
    """
    # Get letter
    sat_sys = SAT_SYSTEM_LETTER[cons_type]

    # Glonass check
    if svid > 50 and cons_type == GLONASS:
        logging.warning("Skip GLONASS sat %s without OSN.", str(svid))
        return SAT_SYSTEM_LETTER[UNKNOWN]

    return sat_sys


def get_epoch_datetime(
    time_nanos: float, full_bias_nanos: float, bias_nanos: float
) -> datetime.datetime:
    """
    Get SEpoch in Datetime format

    :param  time_nanos:     Time Nanoseconds
    :param  full_bias_nanos:Full Bias Nanoseconds
    :param  bias_nanos:     Bias Nanoseconds

    :return gps_datetime    GPS Epoch in Datetime
    """
    # Compute Time
    gps_week = math.floor(-full_bias_nanos * NS_TO_S / GPS_WEEKSECS)
    gps_time = time_nanos - (full_bias_nanos + bias_nanos)
    gps_sow = gps_time * NS_TO_S - gps_week * GPS_WEEKSECS
    gps_datetime = datetime.datetime(1980, 1, 6) + datetime.timedelta(
        weeks=gps_week, seconds=gps_sow
    )

    return gps_datetime


def check_state(cons_type: int, state: int) -> bool:
    """
    Check if Sync is valid

    :param  cons_type:      Constellation type
    :param  state:          State

    :return is_valid        True/False if it is valid/invalid
    """
    # Variables
    is_valid = True

    # Check
    if cons_type != GLONASS and not (state & 2 ^ 0 or state & 2 ^ 3):
        is_valid = False
    if cons_type == GLONASS and not (state & 2 ^ 7 and state & 2 ^ 15):
        is_valid = False

    return is_valid


def get_psdorange(obs: Dict[str, Any]) -> float:
    """
    Calculate Pseudorange

    :param  obs:            Raw Observation

    :return psdorange       Pseudorange
    """
    # Variables
    psdorange = 0.0
    cons_type = obs["ConstellationType"]
    time_nanos = obs["TimeNanos"]
    time_offset_nanos = obs["TimeOffsetNanos"]
    full_bias_nanos = obs["FullBiasNanos"]
    bias_nanos = obs["BiasNanos"]
    received_sv_time_nanos = obs["ReceivedSvTimeNanos"]
    gps_week = math.floor(-full_bias_nanos * NS_TO_S / GPS_WEEKSECS)
    gps_day = math.floor(-full_bias_nanos * NS_TO_S / DAYSEC)

    # Get tRx and tTx
    trx = time_nanos - (full_bias_nanos + bias_nanos)
    ttx = received_sv_time_nanos + time_offset_nanos
    if cons_type in (GPS, GALILEO):
        trx = (trx * NS_TO_S - gps_week * GPS_WEEKSECS) * 1e9
    elif cons_type == GLONASS:
        trx = ((trx * NS_TO_S) - (gps_day * DAYSEC) + (3 * 3600) - 18) * 1e9
    elif cons_type == BEIDOU:
        trx = (trx * NS_TO_S - gps_week * GPS_WEEKSECS - BDST_TO_GPST) * 1e9

    # Compute Travel Time and check week rollover
    tau = (trx - ttx) * NS_TO_S
    if tau > GPS_WEEKSECS / 2:
        del_sec = round(tau / GPS_WEEKSECS) * GPS_WEEKSECS
        rho_sec = tau - del_sec
        if rho_sec > 10:
            tau = 0.0
        else:
            tau = rho_sec

    # Calculate pseudorange
    psdorange = tau * SPEED_OF_LIGHT

    return psdorange


def get_cphase_doppler(obs: Dict[str, Any]) -> Dict[str, Any]:
    """
    Calculate Pseudorange

    :param  obs:            Raw Observation

    :return cphase_doppler  Dictionary with cphase and doppler
    """
    # Variables
    carr_freq = obs["CarrierFrequencyHz"]
    wavelength = SPEED_OF_LIGHT / carr_freq
    acc_delta_range_metters = (
        obs["AccumulatedDeltaRangeMeters"]
        if check_value(
            obs["AccumulatedDeltaRangeMeters"], "AccumulatedDeltaRangeMeters"
        )
        else 0.0
    )
    cphase = ""
    state_adr = obs["AccumulatedDeltaRangeState"]
    if (state_adr & 2 ^ 1) != 0:
        cphase = acc_delta_range_metters / wavelength

    psdo_range_rate_ms = (
        obs["PseudorangeRateMetersPerSecond"]
        if check_value(
            obs["PseudorangeRateMetersPerSecond"], "PseudorangeRateMetersPerSecond"
        )
        else 0.0
    )
    doppler = ""
    if psdo_range_rate_ms != 0.0:
        doppler = -psdo_range_rate_ms / wavelength

    # Check doppler and phase
    if cphase < -100000000.0 or cphase > 100000000.0:
        cphase = 0.0
    
    if doppler < -5000 or doppler > 5000.0:
        doppler = 0.0

    return {"carrierPhase": cphase, "doppler": doppler}


# pylint: disable=too-many-locals
def process_obs(obs: Dict[str, Any]) -> Any:
    """
    Process Observation

    :param  obs:            Raw Observation

    :return obs_dict        Dictionary with Code, Phase, Doppler and SNr
    """
    # Variables
    valid_params = True

    # Time Nanos
    time_nanos = obs["TimeNanos"]

    # Full Bias Nanos
    full_bias_nanos = obs["FullBiasNanos"]
    if not check_value(full_bias_nanos, "FullBiasNanos"):
        valid_params = False

    # Bias Nanos
    bias_nanos = obs["BiasNanos"]
    if not check_value(bias_nanos, "BiasNanos"):
        bias_nanos = 0.0

    # Time Offset Nanos
    time_offset_nanos = obs["TimeOffsetNanos"]
    if not check_value(time_offset_nanos, "TimeOffsetNanos"):
        valid_params = False

    # Constellation Type
    cons_type = obs["ConstellationType"]
    if not check_value(cons_type, "ConstellationType"):
        valid_params = False

    # State
    state = obs["State"]
    if not check_value(state, "State"):
        valid_params = False

    # Svid
    svid = obs["Svid"]
    if not check_value(svid, "Svid"):
        svid = "Invalid"
        valid_params = False

    # Carrier Frequency
    carrier_freq_hz = obs["CarrierFrequencyHz"]
    if not check_value(carrier_freq_hz, "CarrierFrequencyHz"):
        carrier_freq_hz = "Invalid"
        valid_params = False

    # Received SV Time Nanoseconds
    received_sv_time_nanos = obs["ReceivedSvTimeNanos"]
    if not check_value(received_sv_time_nanos, "ReceivedSvTimeNanos"):
        valid_params = False

    # GPS Epoch
    date_gps = get_epoch_datetime(time_nanos, full_bias_nanos, bias_nanos)

    # Return if any parameter is invalid
    if not valid_params:
        logging.warning(
            "Skip band %s for sat %s at %s. No valid parameters.",
            str(carrier_freq_hz),
            str(svid),
            str(date_gps),
        )
        return None

    # Get Satellite System
    sat_sys = sat_system_letter(cons_type, svid)
    sat = (sat_sys + str(svid)) if svid > 9 else (sat_sys + "0" + str(svid))

    # Get Obs Code
    fr_code = freq_code(carrier_freq_hz, cons_type, state)

    if sat_sys == SAT_SYSTEM_LETTER[UNKNOWN] or fr_code == "Invalid":
        logging.warning(
            "Skip band %s for sat %s at %s. No valid Satellite System.",
            str(carrier_freq_hz),
            str(svid),
            str(date_gps),
        )
        return None

    # Return if invalid state
    if not check_state(cons_type, state):
        logging.warning(
            "Skip band %s for sat %s at %s. No valid state (%s).",
            fr_code,
            sat,
            str(date_gps),
            str(state),
        )
        return None

    # Calculate Carrier Phase and Doppler
    psdorange = get_psdorange(obs)
    cphase_doppler = get_cphase_doppler(obs)

    # Check if psdorange is valid
    if psdorange < 0.0 or psdorange > 100000000.0:
        logging.warning(
            "Skip band %s for sat %s at %s. No valid pseudorange.",
            str(carrier_freq_hz),
            str(svid),
            str(date_gps),
        )
        return None

    return {
        "sat": sat,
        "gpsDatetime": date_gps,
        "satObs": {
            "C" + fr_code: psdorange,
            "L" + fr_code: cphase_doppler["carrierPhase"],
            "D" + fr_code: cphase_doppler["doppler"],
            "S" + fr_code: obs["Cn0DbHz"]
            if check_value(obs["Cn0DbHz"], "Cn0DbHz")
            else 0.0,
        },
    }


def rnx3_obs(obs_list: List[Any], obs_freq_av: Dict[str, Any]) -> str:
    """
    Observation line

    :param  obs_dict:       List with all Code, Phase, Doppler and SNr
    :param  obs_freq_av:    Observation Dictionary

    :return obs_line        Observation Line
    """
    # Variables
    obs_sort: Dict[int, Any] = {}
    obs_line = ""
    sat_sys = "G"

    for i, obs in enumerate(obs_list):
        # Get observations and Satellite System
        sat_sys = obs_list[i]["sat"][0]
        sat_obs = obs_list[i]["satObs"]

        # Loop through all obs
        for key in sat_obs:
            # Get freq order
            fr_list = obs_freq_av[sat_sys]
            pos = 0
            for j, value in enumerate(fr_list):
                # Compare observables
                if key == value:
                    pos = j
                    break

            # Create line
            obs = sat_obs[key]
            obs_str = f"{obs:14.3f}"
            obs_sort[pos] = obs_str

    # Line
    fr_list = obs_freq_av[sat_sys]
    for k, value in enumerate(fr_list):
        # Get available values
        obs_str = " "
        obs_str = obs_sort.get(k, f"{obs_str:14s}")
        obs_line += f"{obs_str}" if k == 0 else f"  {obs_str}"

    return obs_line


def rnx3_epoch(gps_datetime: datetime.datetime, num_sats: int) -> str:
    """
    Observation epoch

    :param  gps_datetime:   GPS Epoch in Datetime
    :param  num_sats:       Number of Satellites

    :return epoch_line      Observation epoch
    """
    # Line
    date = f'> {gps_datetime.strftime("%Y %m %d %H %M %S.")}'
    milli = f"{int(gps_datetime.microsecond):06d}"
    time = f"{date}{milli}"
    epoch_line = f"{time}  0 {num_sats:2d}\n"

    return epoch_line


def system_sort(key: str) -> int:
    """
    Short Observables per Satellite System

    :param  key:            Dictionary key

    :return sorted_key      Sorted keys
    """
    return SYSTEM_ORDER.index(key[0]) if key[0] in SYSTEM_ORDER else len(SYSTEM_ORDER)


# pylint: disable=too-many-locals
def create_obs(raw: List[Any], obs_freq_av: Dict[str, Any]) -> Dict[str, Any]:
    """
    Create Observation lines

    :param  raw:            Dictionary with all Raw Data
    :param  obs_freq_av:    Observation Dictionary

    :return obs_dict_fr     Formatted observations
    """
    # Variables
    obs_dict_fr = {}
    obs_dict_per_epoch: Dict[str, Any] = {}
    epoch = (
        raw[0]["TimeNanos"] if check_value(raw[0]["TimeNanos"], "TimeNanos") else 0.0
    )
    obs_str = ""
    num_sats = 0
    first_epoch = False

    # Loop throught all observations
    for i, value in enumerate(raw):
        # Time Nanos
        time_nanos = value["TimeNanos"]
        if check_value(time_nanos, "TimeNanos"):
            # Process Obs
            obs_dict = process_obs(value)

            # Check if valid obs
            if obs_dict is not None:
                # Save First Epoch
                if not first_epoch:
                    epoch_datetime = obs_dict_fr["firstEpoch"] = obs_dict["gpsDatetime"]
                    first_epoch = True

                # Save in dict per satellite
                if obs_dict["sat"] not in obs_dict_per_epoch:
                    obs_dict_per_epoch[obs_dict["sat"]] = []
                    obs_dict_per_epoch[obs_dict["sat"]].append(obs_dict)
                    num_sats += 1
                else:
                    obs_dict_per_epoch[obs_dict["sat"]].append(obs_dict)

                # Chek if same epoch
                if epoch != time_nanos or i == len(raw) - 1:
                    # Print previous block
                    epoch_line = rnx3_epoch(epoch_datetime, num_sats)
                    obs_str += epoch_line

                    # Sort
                    sorted_keys = sorted(obs_dict_per_epoch.keys(), key=system_sort)
                    sorted_dict = {key: obs_dict_per_epoch[key] for key in sorted_keys}

                    # Get Obs line
                    for key, itm in sorted_dict.items():
                        sat_obs = itm
                        obs_line = rnx3_obs(sat_obs, obs_freq_av)
                        obs_str += f"{key}{obs_line}\n"

                    # Update to new epoch
                    epoch_datetime = obs_dict["gpsDatetime"]
                    epoch = time_nanos
                    num_sats = 0
                    obs_dict_per_epoch = {}
                else:
                    epoch_datetime = obs_dict["gpsDatetime"]

    obs_dict_fr["obsString"] = obs_str

    return obs_dict_fr
