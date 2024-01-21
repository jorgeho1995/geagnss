///////////////////////////////////////////////////////////////////////
//// app.js
///////////////////////////////////////////////////////////////////////
//////////////////////////////
//// Includes and Constants
//////////////////////////////
// Includes
const rtcm = require("@gnss/rtcm");
const nmea = require("@gnss/nmea");
const uint32 = require('uint32');
const WebSocket = require("ws");
const http = require('http');
const express = require("express");
const net = require('net');
const fs = require('fs');
const { spawn } = require("child_process");
// App constants
const hostname = '127.0.0.1';
const port = 3000;
const wsPort = 5556;
const BNCPort = 1234;
const PATH = "/home/ubuntu/GEA/rt/";
const RTKLIB_PATH = "/home/ubuntu/GEA/GEA_server/rtklib/rtknavi_qt";
const RTKLIB_CONF = "/home/ubuntu/GEA/GEA_server/rtklib/rtknavi_qt.ini";
// Execution Message Types
const LAUNCH = 0;
const MSG = 1;
const STOP = 2;
// Contellation IDs
const GPS = 1;
const SBAS = 2;
const GLONASS = 3;
const QZSS = 4;
const BEIDOU = 5;
const GALILEO = 6;
const UNKNOWN = 0;
// Calculation Constants
const SPEED_OF_LIGHT = 299792458.0;
const GPS_WEEKSECS = 604800;
const NS_TO_S = 1.0e-9;
const S_TO_MS = 1.0e3
const NS_TO_M = NS_TO_S * SPEED_OF_LIGHT;
const BDST_TO_GPST = 14;
const GLOT_TO_UTC = 10800;
const DAYSEC = 86400;
const RANGE_MS = SPEED_OF_LIGHT * 0.001;
const P2_10 = 0.0009765625; // 2^-10
const P2_24 = 5.960464477539063E-08 // 2^-24
const P2_29 = 1.862645149230957E-09 // 2^-29
// Position in RAW message
const utcTimeMillis = 1;
const TimeNanos = 2;
const LeapSecond = 3;
const TimeUncertaintyNanos = 4;
const FullBiasNanos = 5;
const BiasNanos = 6;
const BiasUncertaintyNanos = 7;
const DriftNanosPerSecond = 8;
const DriftUncertaintyNanosPerSecond = 9;
const HardwareClockDiscontinuityCount = 10;
const Svid = 11;
const TimeOffsetNanos = 12;
const State = 13;
const ReceivedSvTimeNanos = 14;
const ReceivedSvTimeUncertaintyNanos = 15;
const Cn0DbHz = 16;
const PseudorangeRateMetersPerSecond = 17;
const PseudorangeRateUncertaintyMetersPerSecond = 18;
const AccumulatedDeltaRangeState = 19;
const AccumulatedDeltaRangeMeters = 20;
const AccumulatedDeltaRangeUncertaintyMeters = 21;
const CarrierFrequencyHz = 22;
const CarrierCycles = 23;
const CarrierPhase = 24;
const CarrierPhaseUncertainty = 25;
const MultipathIndicator = 26;
const SnrInDb = 27;
const ConstellationType = 28;
const AgcDb = 29;
const BasebandCn0DbHz = 30;
const FullInterSignalBiasNanos = 31;
const FullInterSignalBiasUncertaintyNanos = 32;
const SatelliteInterSignalBiasNanos = 33;
const SatelliteInterSignalBiasUncertaintyNanos = 34;
const CodeType = 35;
const ChipsetElapsedRealtimeNanos = 36;

///////////////////////////////////////////////////////////////////////
//// WEB APP
///////////////////////////////////////////////////////////////////////
//////////////////////////////
/// WEB INDEX
//////////////////////////////
const app = express();
app.use(express.static('static'));
app.use(express.static('assets'));
app.get("/", function (request, response) {
  response.sendFile(__dirname + "/views/index.html");
});
app.listen(port, () => console.log(`Server listening on port: ${port}`));

//////////////////////////////
/// SERVER TIME
//////////////////////////////
app.get('/getServerTime', function (req, res) {
  const serverTime = new Date();
  res.json({ serverTime: serverTime.toISOString() });
});

//////////////////////////////
/// WEBSOCKET
//////////////////////////////
const wss = new WebSocket.Server({ port: wsPort });
wss.on("connection", (ws, request) => {
  // Connected to server
  let success = true;
  const clientIP = request.socket.remoteAddress;
  console.log(`[Websocket] Client with IP ${clientIP} has connected`);
  ws.send("EVENT: You've just connected to the server! Creating execution, please wait... Status (1).");

  // TCP Client init to send data to RTKLIB
  const clientRTKLIB = new net.Socket();

  // TCP Client init to receive data from RTKLIB
  const clientRTKLIBRec = new net.Socket();

  // TCP Client to receive Ephemeris
  const clientBNC = new net.Socket();

  // Receiving Message from Smartphone on Websockets
  ws.on("message", message => {
    let msgJson = JSON.parse(message);
    success = launchExecution(msgJson, ws, clientRTKLIB, clientRTKLIBRec, clientBNC);
    if (!success) {
      ws.send("ERROR: Launch failed. Status (-1).");
      endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson);
    }
  });
});

///////////////////////////////////////////////////////////////////////
//// FUNCTIONS
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
/// End RTKLIB process and client sessions
///
/// Inputs:
///   TCPC     clientRTKLIB      TCP Client to connect with RTKLIB
///   TCPC     clientRTKLIBRec   TCP Client to connect with RTKLIB
///   TCPC     clientBNC         TCP Client to connect with RTKLIB
///   JSON     msgJson           Message from smartphone
///////////////////////////////////////////////////////////////////////
async function endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson) {
  // Finish client connections
  let user = msgJson["User"];
  let folderName = PATH + user;
  // User ID
  let userID = msgJson["clientRTKLIBPort"].toString() + msgJson["clientRTKLIBRecPort"].toString();
  try {
    clientRTKLIB.end();
    clientRTKLIBRec.end();
    clientBNC.end();
    await new Promise(resolve => setTimeout(resolve, 5000));
    spawn('killall', ['rtknavi_qt_' + userID], {
      detached: true
    });
    await new Promise(resolve => setTimeout(resolve, 2000));
    spawn('rm', [folderName + '/rtknavi_qt_' + userID], {
      detached: true
    });
    await new Promise(resolve => setTimeout(resolve, 2000));
    spawn('rm', [folderName + '/rtknavi_qt_' + userID + '.ini'], {
      detached: true
    });
  } catch {
    console.log("Error closing connections. Review possible open jobs");
  }
}

///////////////////////////////////////////////////////////////////////
/// Main function launcher
///
/// Inputs:
///   JSON     msgJson           Message from smartphone
///   WebS     ws                Websocket connection
///   TCPC     clientRTKLIB      TCP Client to connect with RTKLIB
///   TCPC     clientRTKLIBRec   TCP Client to connect with RTKLIB
///   TCPC     clientBNC         TCP Client to connect with RTKLIB
///
/// Outputs:
///   Bool     success     True if launch/send works, False else 
///////////////////////////////////////////////////////////////////////
async function launchExecution(msgJson, ws, clientRTKLIB, clientRTKLIBRec, clientBNC) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let success = true; 
  // Type of message received
  let mType = parseValue(msgJson["MessageType"], 'int'); 

  // Launch/Process/Stop
  switch (mType) {
    case LAUNCH:
      // Add error exceptions
      clientRTKLIB.on('error', error => {
        ws.send("ERROR: Launch failed. Cannot connect to RTKLIB. Status (-1).");
        endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson);
      });
      clientRTKLIBRec.on('error', error => {
        ws.send("ERROR: Launch failed. Cannot receive data from RTKLIB. Status (-1).");
        endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson);
      });
      clientBNC.on('error', error => {
        ws.send("ERROR: Launch failed. Cannot connect to BNC. Status (-1).");
        endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson);
      });

      // Read ports from config
      let portTCP = parseValue(msgJson["clientRTKLIBPort"], 'int');
      let portTCPRec = parseValue(msgJson["clientRTKLIBRecPort"], 'int');

      // Create Scenario
      let user = msgJson["User"];
      let folderName = PATH + user;

      // Create folder
      if (!fs.existsSync(folderName)) {
        fs.mkdirSync(folderName);
      }

      // User ID
      let userID = msgJson["clientRTKLIBPort"].toString() + msgJson["clientRTKLIBRecPort"].toString();

      // Copy files
      fs.copyFile(RTKLIB_PATH, folderName + '/rtknavi_qt_' + userID, (err) => {
        if (err) return false;
      });

      // Modify .ini file
      let filename = folderName + '/rtknavi_qt_' + userID + '.ini';
      writeConfigFile(filename, portTCP, portTCPRec, folderName, msgJson["Content"]);
      // Launch RTKLIB
      spawn('xvfb-run', ['-a', folderName + '/rtknavi_qt_' + userID, '--auto'], {
        detached: true
      });
      await new Promise(resolve => setTimeout(resolve, 5000));

      // Connection to BNC
      clientBNC.connect(BNCPort, hostname, function() {
        ws.send("EVENT: Connected to BNC. Receiving Navigation Messages. Status (1).");
      });

      // Connection to RTKLIB
      clientRTKLIB.connect(portTCP, hostname, function() {
        ws.send("EVENT: Connected to RTKLIB. Status (1).");
        ws.send("EVENT: Ready to Start. Status (2).");
      });
      clientRTKLIBRec.connect(portTCPRec, hostname, function() {
        ws.send("EVENT: Receiving data from RTKLIB. Status (1).");
      });

      // Send Solution to GEA
      clientRTKLIBRec.on('data', function(chunk) {
        let nmeaMsgs = [];
        nmeaMsgs = chunk.toString('utf8').split("\r\n");
        for (let i=0; i<nmeaMsgs.length-1; i++) {
          ws.send(nmeaMsgs[i]);
          let nmeaDec = nmea.NmeaTransport.decode(nmeaMsgs[i]);
          nmeaDec["nmeaType"] = nmea.NmeaTransport.decode(nmeaMsgs[i]).sentenceType;
          ws.send(JSON.stringify(nmeaDec));
        }
        ws.send(generateTimeStampNMEA("2"));
      });

      // Send received data to RTKLIB
      clientBNC.on('data', function(chunk) {
        clientRTKLIB.write(chunk);
      });
      break;
    case MSG:
      // Encode RAW message and send
      ws.send(generateTimeStampNMEA("1"));
      success = encodeAndSendMSG(msgJson["Content"], clientRTKLIB);
      break;
    case STOP:
      ws.send("EVENT: Launch Stopped. Status (0).");
      endExecution(clientRTKLIB, clientRTKLIBRec, clientBNC, msgJson);
      success = true;
      break;
    default:
      success = false;
      break;
  }

  // Return Status
  return success;
}

///////////////////////////////////////////////////////////////////////
/// Preprocess Raw Messages
///
/// Inputs:
///   JSON      msgJSON    JSON object with all received messages
///
/// Outputs:
///   Obj       procMsg    JSON object with all sats info processed
///////////////////////////////////////////////////////////////////////
function preprocRawMSG(msgJSON) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let satInfoG = {};
  let satInfoR = {};
  let satInfoE = {};
  let satInfoC = {};

  // Loop through all Raw Messages
  for (let key in msgJSON) {
    // Split values from message and order in Obj
    let satInfo = {}
    let msg = msgJSON[key].split(",");
    let constellation = parseValue(msg[ConstellationType], 'int');
    let idSat = parseValue(msg[Svid], 'int');

    // Store in Obj
    satInfo["utcTimeMillis"] = parseValue(msg[utcTimeMillis], 'int');
    satInfo["TimeNanos"] = parseValue(msg[TimeNanos], 'int');
    satInfo["LeapSecond"] = parseValue(msg[LeapSecond], 'int');
    satInfo["TimeUncertaintyNanos"] = parseValue(msg[TimeUncertaintyNanos], 'float');
    satInfo["FullBiasNanos"] = parseValue(msg[FullBiasNanos], 'int');
    satInfo["BiasNanos"] = parseValue(msg[BiasNanos], 'float');
    satInfo["BiasUncertaintyNanos"] = parseValue(msg[BiasUncertaintyNanos], 'float');
    satInfo["DriftNanosPerSecond"] = parseValue(msg[DriftNanosPerSecond], 'float');
    satInfo["DriftUncertaintyNanosPerSecond"] = parseValue(msg[DriftUncertaintyNanosPerSecond], 'float');
    satInfo["HardwareClockDiscontinuityCount"] = parseValue(msg[HardwareClockDiscontinuityCount], 'int');
    satInfo["Svid"] = parseValue(msg[Svid], 'int');
    satInfo["TimeOffsetNanos"] = parseValue(msg[TimeOffsetNanos], 'float');
    satInfo["State"] = parseValue(msg[State], 'int');
    satInfo["ReceivedSvTimeNanos"] = parseValue(msg[ReceivedSvTimeNanos], 'int');
    satInfo["ReceivedSvTimeUncertaintyNanos"] = parseValue(msg[ReceivedSvTimeUncertaintyNanos], 'int');
    satInfo["Cn0DbHz"] = parseValue(msg[Cn0DbHz], 'float');
    satInfo["PseudorangeRateMetersPerSecond"] = parseValue(msg[PseudorangeRateMetersPerSecond], 'float');
    satInfo["PseudorangeRateUncertaintyMetersPerSecond"] = parseValue(msg[PseudorangeRateUncertaintyMetersPerSecond], 'float');
    satInfo["AccumulatedDeltaRangeState"] = parseValue(msg[AccumulatedDeltaRangeState], 'int');
    satInfo["AccumulatedDeltaRangeMeters"] = parseValue(msg[AccumulatedDeltaRangeMeters], 'float');
    satInfo["AccumulatedDeltaRangeUncertaintyMeters"] = parseValue(msg[AccumulatedDeltaRangeUncertaintyMeters], 'float');
    satInfo["CarrierFrequencyHz"] = parseValue(msg[CarrierFrequencyHz], 'float');
    satInfo["CarrierCycles"] = parseValue(msg[CarrierCycles], 'int');
    satInfo["CarrierPhase"] = parseValue(msg[CarrierPhase], 'int');
    satInfo["CarrierPhaseUncertainty"] = parseValue(msg[CarrierPhaseUncertainty], 'int');
    satInfo["MultipathIndicator"] = parseValue(msg[MultipathIndicator], 'int');
    satInfo["SnrInDb"] = parseValue(msg[SnrInDb], 'float');
    satInfo["ConstellationType"] = parseValue(msg[ConstellationType], 'int');
    satInfo["AgcDb"] = parseValue(msg[AgcDb], 'float');
    satInfo["BasebandCn0DbHz"] = parseValue(msg[BasebandCn0DbHz], 'float');
    satInfo["FullInterSignalBiasNanos"] = parseValue(msg[FullInterSignalBiasNanos], 'float');
    satInfo["FullInterSignalBiasUncertaintyNanos"] = parseValue(msg[FullInterSignalBiasUncertaintyNanos], 'float');
    satInfo["SatelliteInterSignalBiasNanos"] = parseValue(msg[SatelliteInterSignalBiasNanos], 'float');
    satInfo["SatelliteInterSignalBiasUncertaintyNanos"] = parseValue(msg[SatelliteInterSignalBiasUncertaintyNanos], 'float');
    satInfo["CodeType"] = msg[CodeType];
    satInfo["ChipsetElapsedRealtimeNanos"] = parseValue(msg[ChipsetElapsedRealtimeNanos], 'int');

    // Store by constellation
    switch (constellation) {
      case GPS:
        // Check if it is a new sat or new freq
        if (idSat in satInfoG) {
          let satArr = satInfoG[idSat];
          satArr.push(satInfo);
          satInfoG[idSat] = satArr;
        } else {
          satInfoG[idSat] = [satInfo];
        }
        break;
      case GLONASS:
        // Check if it is a new sat or new freq
        if (idSat in satInfoR) {
          let satArr = satInfoR[idSat];
          satArr.push(satInfo);
          satInfoR[idSat] = satArr;
        } else {
          satInfoR[idSat] = [satInfo];
        }
        break;
      case GALILEO:
        // Check if it is a new sat or new freq
        if (idSat in satInfoE) {
          let satArr = satInfoE[idSat];
          satArr.push(satInfo);
          satInfoE[idSat] = satArr;
        } else {
          satInfoE[idSat] = [satInfo];
        }
        break;
      case BEIDOU:
        // Check if it is a new sat or new freq
        if (idSat in satInfoC) {
          let satArr = satInfoC[idSat];
          satArr.push(satInfo);
          satInfoC[idSat] = satArr;
        } else {
          satInfoC[idSat] = [satInfo];
        }
        break;
      default:
        break;
    }
  }

  return {"GPS": satInfoG, "Glonass": satInfoR, "Galileo": satInfoE, "Beidou": satInfoC};
}

///////////////////////////////////////////////////////////////////////
/// Generates the RTCM content of the message
///
/// Inputs:
///   JSON      procMsg    JSON object with all sats info processed
///   Bool      lastMsg    Flag to indicate last msg to send
///
/// Outputs:
///   Obj       msgObj     Object with the RTCM msg 
///////////////////////////////////////////////////////////////////////
function generateMsg(consSats, lastMsg) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let sats = [];

  ///////////////////////////////////////////////////////////////////////
  /// Loop into all messages and create satellites array
  ///////////////////////////////////////////////////////////////////////
  let msmSatPar = {};
  for (let key in consSats) {
    // Get Satellite Array
    let freq = consSats[key];
    let signals = [];

    // Create signals Array
    for (let i=0; i < freq.length; i++) {
      let constell = freq[i]["ConstellationType"];
      let carrFreq = freq[i]["CarrierFrequencyHz"];
      let idFreq = getRTCMFreqIds(constell, carrFreq);
      if(idFreq == 2)// Get MSM Satellite parameters with L1
      {
        msmSatPar = getMSMSatsParams(freq[0]);
      }
      if(idFreq != 13) { // Skip B2A Frequency
        let msmSigPar = getMSMSignParams(freq[i]);
        let signal = rtcm.Msm5SignalData.construct({
          id: msmSigPar["idFreq"],
          finePseudorange: msmSigPar["finePseudorange"],
          finePhaserange: msmSigPar["finePhaserange"],
          phaserangeLockTimeIndicator: msmSigPar["phaserangeLockTimeIndicator"],
          halfCycleAmbiguityIndicator: msmSigPar["halfCycleAmbiguityIndicator"],
          cnr: msmSigPar["cnr"],
          finePhaserangeRate: msmSigPar["finePhaserangeRate"],
        });
        signals.push(signal);
      }
    }

    // Create Satellite Data
    let msm5 = rtcm.Msm5SatelliteData.construct({
      id: msmSatPar['satId'],
      roughRangeIntegerMilliseconds: msmSatPar['roughRangeIntegerMilliseconds'],
      extendedInformation: msmSatPar['extendedInformation'],
      roughRangeModulo1Millisecond: msmSatPar['roughRangeModulo1Millisecond'],
      roughPhaserangeRateMetersPerSecond: msmSatPar['roughPhaserangeRateMetersPerSecond'],
      signals: signals,
    });

    // Add satellite to list
    sats.push(msm5);
  }

  ///////////////////////////////////////////////////////////////////////
  /// Create RTCM message
  ///////////////////////////////////////////////////////////////////////
  let msgObj = {
    referenceStationId: 1234,
    gnssEpochTime: msmSatPar['gnssEpochTime'],
    multipleMessage: lastMsg,
    issueOfDataStation: 0,
    clockSteeringIndicator: 0,
    externalClockIndicator: 0,
    divergenceFreeSmoothingIndicator: false,
    smoothingInterval: 0,
    satellites: sats,
  };

  // Return RTCM message
  return msgObj;
}

///////////////////////////////////////////////////////////////////////
/// Encode GNSS Raw data and send to the caster
///
/// Inputs:
///   JSON      msgJSON          JSON object with all received messages
///   TCPC      clientRTKLIB     TCP Client to connect with RTKLIB
///
/// Outputs:
///   Bool      success    True if msg sent, False else
///////////////////////////////////////////////////////////////////////
function encodeAndSendMSG(msgJSON, clientRTKLIB) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let msgRTCM;
  let msgObj;
  let buffer;
  let length;
  let bufferMsgs = [];
  let bufferLength = 0;
  // TODO: Enable multiple message Flag depending on config or constellation

  ///////////////////////////////////////////////////////////////////////
  /// Preprocess Raw Messages
  ///////////////////////////////////////////////////////////////////////
  procMsg = preprocRawMSG(msgJSON);

  ///////////////////////////////////////////////////////////////////////
  /// Create an encode messages
  ///////////////////////////////////////////////////////////////////////
  let isGPSAvailable = Object.keys(procMsg['GPS']).length !== 0;
  let isGLOAvailable = Object.keys(procMsg['Glonass']).length !== 0;
  let isGALAvailable = Object.keys(procMsg['Galileo']).length !== 0;
  let isBEIAvailable = Object.keys(procMsg['Beidou']).length !== 0;
  
  ///////////////////////
  /// GPS
  ///////////////////////
  if (isGPSAvailable) {
    // Generate message
    let lastMsg = (isGLOAvailable || isGALAvailable || isBEIAvailable);
    msgObj = generateMsg(procMsg['GPS'], lastMsg);
    msgRTCM = rtcm.RtcmMessageMsm5Gps.construct(msgObj);
    buffer = Buffer.allocUnsafe(rtcm.RtcmTransport.MAX_PACKET_SIZE);
    length = rtcm.RtcmTransport.encode(msgRTCM, buffer);
    buffer = buffer.slice(0, length);
    bufferMsgs.push(buffer);
    bufferLength += buffer.length;
  }

  ///////////////////////
  /// GLONASS
  ///////////////////////
  if (isGLOAvailable) {
    // Generate message
    let lastMsg = (isGALAvailable || isBEIAvailable);
    msgObj = generateMsg(procMsg['Glonass'], lastMsg);
    msgRTCM = rtcm.RtcmMessageMsm5Glonass.construct(msgObj);
    buffer = Buffer.allocUnsafe(rtcm.RtcmTransport.MAX_PACKET_SIZE);
    length = rtcm.RtcmTransport.encode(msgRTCM, buffer);
    buffer = buffer.slice(0, length);
    bufferMsgs.push(buffer);
    bufferLength += buffer.length;
  }

  ///////////////////////
  /// GALILEO
  ///////////////////////
  if (isGALAvailable) {
    // Generate message
    let lastMsg = isBEIAvailable;
    msgObj = generateMsg(procMsg['Galileo'], lastMsg);
    msgRTCM = rtcm.RtcmMessageMsm5Galileo.construct(msgObj);
    buffer = Buffer.allocUnsafe(rtcm.RtcmTransport.MAX_PACKET_SIZE);
    length = rtcm.RtcmTransport.encode(msgRTCM, buffer);
    buffer = buffer.slice(0, length);
    bufferMsgs.push(buffer);
    bufferLength += buffer.length;
  }

  ///////////////////////
  /// BEIDOU
  ///////////////////////
  if (isBEIAvailable) {
    // Generate message
    msgObj = generateMsg(procMsg['Beidou'], false);
    msgRTCM = rtcm.RtcmMessageMsm5Bds.construct(msgObj);
    buffer = Buffer.allocUnsafe(rtcm.RtcmTransport.MAX_PACKET_SIZE);
    length = rtcm.RtcmTransport.encode(msgRTCM, buffer);
    buffer = buffer.slice(0, length);
    bufferMsgs.push(buffer);
    bufferLength += buffer.length;
  }

  ///////////////////////////////////////////////////////////////////////
  /// Concat buffers and send message to RTKLIB
  ///////////////////////////////////////////////////////////////////////
  let send = Buffer.concat(bufferMsgs, bufferLength);
  clientRTKLIB.write(send);

  // Return True/False TODO: Add true/false exceptions
  return true;
}

///////////////////////////////////////////////////////////////////////
/// Calculate GNSS Time
///
/// Inputs:
///   Obj       satObj     Object with a received messages
///
/// Outputs:
///   int       gnssTime   GNSS Time depending on the constellation
///////////////////////////////////////////////////////////////////////
function calcGNSSTime(satObj) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let gnssTime = 0.0;
  let constellation = satObj['ConstellationType'];
  let timeNanos = satObj['TimeNanos'];
  let fullBiasNanos = satObj['FullBiasNanos'];
  let biasNanos = satObj['BiasNanos'];
  let leapSeconds = 18;

  // Check if it is valid parameters
  if (timeNanos!='' && fullBiasNanos!='') {
    let gpsWeek = Math.floor(-fullBiasNanos * NS_TO_S / GPS_WEEKSECS);
    let localGNSSTime = timeNanos - (fullBiasNanos + biasNanos);
    let gpsSOW = localGNSSTime * NS_TO_S - gpsWeek * GPS_WEEKSECS;
    let gpsDay = Math.floor(-fullBiasNanos * NS_TO_S / DAYSEC);
    switch (constellation) {
      case GPS: 
      case GALILEO:
        gnssTime = gpsSOW;
        break;
      case GLONASS:
        gnssTime = (localGNSSTime * NS_TO_S) - (gpsDay * DAYSEC) + (3 * 3600) - leapSeconds;
        break;
      case BEIDOU:
        gnssTime = gpsSOW - BDST_TO_GPST;
        break;
      default:
        break;
    }
  }
  
  // Return time in milliseconds
  return gnssTime * S_TO_MS;
}

///////////////////////////////////////////////////////////////////////
/// Parse Raw values to Int or Float
///
/// Inputs:
///   String    value      Raw Value
///   String    type       'int' or 'float'
///
/// Outputs:
///   int/float valParsed  Value parsed
///////////////////////////////////////////////////////////////////////
function parseValue(value, type) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let valParsed = 0;

  // Parse values
  switch(type) {
    case 'int':
      if (value != '') {
        valParsed = parseInt(value);
      } else {
        valParsed = 0;
      }
      break;
    case 'float':
      if (value != '') {
        valParsed = parseFloat(value);
      } else {
        valParsed = 0;
      }
      break;
    default:
      break;
  }

  // Return parsed values
  return valParsed;
}

///////////////////////////////////////////////////////////////////////
/// Round values
///
/// Inputs:
///   int/float value      Value to round          
///
/// Outputs:
///   int       valRound   Value rounded
///////////////////////////////////////////////////////////////////////
function ROUND(value) {
  return parseValue(Math.floor(value + 0.5), 'int');
}

///////////////////////////////////////////////////////////////////////
/// Round values
///
/// Inputs:
///   int/float value      Value to round          
///
/// Outputs:
///   uint32    valRound   Value rounded
///////////////////////////////////////////////////////////////////////
function ROUND_U(value) {
  return uint32.toUint32(Math.floor(value + 0.5));
}

///////////////////////////////////////////////////////////////////////
/// Get Satellite Pseudorange
///
/// Inputs:
///   Obj       satObj     Object with sat data (first frequency)
///
/// Outputs:
///   float     psdoRange  Pseudorange in meters
///////////////////////////////////////////////////////////////////////
function getPsdoRange(satObj) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let psdoRange = 0.0;
  let constellation = satObj['ConstellationType'];
  let timeNanos = satObj['TimeNanos'];
  let timeOffsetNanos = satObj['TimeOffsetNanos'];
  let fullBiasNanos = satObj['FullBiasNanos'];
  let biasNanos = satObj['BiasNanos'];
  let receivedSvTimeNanos = satObj['ReceivedSvTimeNanos'];
  let leapSeconds = 18;
  let state = satObj['State'];
  let gpsWeek = Math.floor(-fullBiasNanos * NS_TO_S / GPS_WEEKSECS);
  let gpsDay = Math.floor(-fullBiasNanos * NS_TO_S / DAYSEC);
  let gps100mili = Math.floor(-fullBiasNanos * NS_TO_S / 0.1);

  // State: ToW must be decoded
  if( constellation != GLONASS && !(state & 2^0 || state & 2^3) )
  {
    return 0;
  }

  if( constellation == GLONASS && !(state & 2^7 && state & 2^15) )
  {
    return 0;
  }

  // Get tRx and tTx
  let tRx = timeNanos - (fullBiasNanos + biasNanos);
  let tTx = receivedSvTimeNanos + timeOffsetNanos;
  switch (constellation) {
    case GPS:
    case GALILEO:
      tRx = (tRx * NS_TO_S - gpsWeek * GPS_WEEKSECS) * 1e9;
      break;
    case GLONASS:
      tRx = ((tRx * NS_TO_S) - (gpsDay * DAYSEC) + (3 * 3600) - leapSeconds) * 1e9;
      break;
    case BEIDOU:
      tRx = (tRx * NS_TO_S - gpsWeek * GPS_WEEKSECS - BDST_TO_GPST) * 1e9;
      break;
    default:
      tRx = 0.0;
      tTx = 0.0;
      break;
  }

  let tau = (tRx - tTx) * NS_TO_S;
  if (tau > GPS_WEEKSECS / 2) {
    let delSec = ROUND( tau/GPS_WEEKSECS ) * GPS_WEEKSECS;
    let rhoSec = tau - delSec;
    if (rho_sec > 10) {
        tau = 0.0
    } else {
      tau = rhoSec
    }
  }

  // Calculate pseudorange
  psdoRange = tau * SPEED_OF_LIGHT;

  // Return pseudorange
  return psdoRange;
}
///////////////////////////////////////////////////////////////////////
/// Get Satellite Carrier Phase and Doppler
///
/// Inputs:
///   Obj       satObj           Object with sat data (first frequency)
///
/// Outputs:
///   Obj       cPhase, doppler  Carrier Phase and Doppler in Hz
///////////////////////////////////////////////////////////////////////
function getCPhaseDoppler(satObj) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  // TODO: Add checks of carrier phase
  let carrFreq = satObj["CarrierFrequencyHz"];
  let wavelength = SPEED_OF_LIGHT / carrFreq;
  let cPhase = satObj['AccumulatedDeltaRangeMeters'] / wavelength;
  let doppler = - satObj['PseudorangeRateMetersPerSecond'] / wavelength;

  // Return pseudorange
  return {'CarrierPhase': cPhase, 'Doppler': doppler};
}

///////////////////////////////////////////////////////////////////////
/// Get Satellite Parameters for MSM
///
/// Inputs:
///   Obj       satObj     Object with sat data (first frequency)
///
/// Outputs:
///   Obj       msmSatPar  MSM Satellite Parameters
///////////////////////////////////////////////////////////////////////
function getMSMSatsParams(satObj) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let msmSatPar = {};

  // Get GNSS Epoch Time
  let gnssEpochTime = calcGNSSTime(satObj);
  msmSatPar["gnssEpochTime"] = ROUND_U(gnssEpochTime);

  // Get Satellie Id
  let satId = satObj['Svid']; // TODO: Review RTCM Tables
  msmSatPar['satId'] = satId;

  // Calculate Rough Range Integer
  let psdoRange = getPsdoRange(satObj);
  let roughRangeIntegerMilliseconds = ROUND(psdoRange/RANGE_MS/P2_10) * RANGE_MS * P2_10;
  if(roughRangeIntegerMilliseconds == 0.0){
    intMs = 255;
  } else if(roughRangeIntegerMilliseconds < 0.0 || roughRangeIntegerMilliseconds > RANGE_MS*255.0) {
    intMs = 255;
  } else {
    intMs = ROUND_U(roughRangeIntegerMilliseconds/RANGE_MS/P2_10)>>10;
  }
  msmSatPar['roughRangeIntegerMilliseconds'] = intMs;

  // Get Extended Information 
  let extendedInformation = 0; // TODO: Finish for GLO
  msmSatPar['extendedInformation'] = extendedInformation;

  // Calculate Rough Range Integer modulo
  let roughRangeModulo1Millisecond = 0;
  if (roughRangeIntegerMilliseconds > 0.0 && roughRangeIntegerMilliseconds <= RANGE_MS*255.0) {
    roughRangeModulo1Millisecond = ROUND_U(roughRangeIntegerMilliseconds/RANGE_MS/P2_10)&1023;
  }
  msmSatPar['roughRangeModulo1Millisecond'] = roughRangeModulo1Millisecond;

  // Get Rough Phase Range Rate
  let carrFreq = satObj["CarrierFrequencyHz"];
  let cPhaseDoppler = getCPhaseDoppler(satObj)
  let doppler = cPhaseDoppler['Doppler'];
  let roughPhaserangeRateMetersPerSecond = ROUND(doppler*SPEED_OF_LIGHT/carrFreq)*1.0;
  if(Math.abs(roughPhaserangeRateMetersPerSecond) > 8191.0){
    rrateVal = -8192;
  } else {
    rrateVal = ROUND(roughPhaserangeRateMetersPerSecond/1.0);
  }
  msmSatPar['roughPhaserangeRateMetersPerSecond'] = rrateVal;

  // Return Satellite Parameters
  return msmSatPar;
}

///////////////////////////////////////////////////////////////////////
/// Get Signal Parameters for MSM
///
/// Inputs:
///   Arr       freqArr    Array with satellite info
///
/// Outputs:
///   Obj       msmSigPar  MSM Signal Parameters
///////////////////////////////////////////////////////////////////////
function getMSMSignParams(freqArr) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  let msmSigPar = {};

  // Get Frequency Id
  let constell = freqArr["ConstellationType"];
  let carrFreq = freqArr["CarrierFrequencyHz"];
  let idFreq = getRTCMFreqIds(constell, carrFreq);
  msmSigPar['idFreq'] = idFreq;

  // Calculate Fine PsdoRange
  let psdoRange = getPsdoRange(freqArr);
  let rrng = ROUND(psdoRange/RANGE_MS/P2_10) * RANGE_MS * P2_10;
  let finePseudorange = psdoRange - rrng;
  if(finePseudorange == 0.0){
    finePseudorange = -16384;
  } else if(Math.abs(finePseudorange) > 292.7) {
    finePseudorange = -16384;
  } else {
    finePseudorange = ROUND(finePseudorange/RANGE_MS/P2_24);
  }
  msmSigPar['finePseudorange'] = finePseudorange;

  // Calculate Fine Phase Range
  let wavelength = SPEED_OF_LIGHT / carrFreq;
  let lambda = carrFreq == 0.0 ? 0.0 : wavelength;
  let cPhaseDoppler = getCPhaseDoppler(freqArr)
  let cPhase = cPhaseDoppler['CarrierPhase'];
  let doppler = cPhaseDoppler['Doppler'];
  let finePhaserange = cPhase == 0.0 || lambda <= 0.0 ? 0.0 : cPhase * lambda - rrng;
  if(finePhaserange == 0.0){
    finePhaserange = -2097152;
  } else if(Math.abs(finePhaserange) > 1171.0) {
    finePhaserange = -2097152;
  } else {
    finePhaserange = ROUND(finePhaserange/RANGE_MS/P2_29);
  }
  msmSigPar['finePhaserange'] = finePhaserange;

  // Get Phase Range Lock Indicator
  let phaserangeLockTimeIndicator = 0; // TODO: Finish phase parameters
  msmSigPar['phaserangeLockTimeIndicator'] = phaserangeLockTimeIndicator;

  let halfCycleAmbiguityIndicator = false; // TODO: Finish phase parameters
  msmSigPar['halfCycleAmbiguityIndicator'] = halfCycleAmbiguityIndicator;

  // Get CNR
  let cnr = ROUND((freqArr['Cn0DbHz'])/1.0); // TODO: Review CNR
  msmSigPar['cnr'] = cnr;

  // Calculate Fine Pahse Rate
  let rrate = ROUND(doppler*wavelength)*1.0;
  let finePhaserangeRate = doppler == 0.0 || lambda <= 0.0 ? 0.0 : -doppler * lambda - rrate;
  if(finePhaserangeRate == 0.0){
    finePhaserangeRate = -16384;
  } else if(Math.abs(finePhaserangeRate) > 1.6384) {
    finePhaserangeRate = -16384;
  } else {
    finePhaserangeRate = ROUND(finePhaserangeRate/0.0001);
  }
  msmSigPar['finePhaserangeRate'] = finePhaserangeRate;

  // Return Signal Parameters
  return msmSigPar;
}

///////////////////////////////////////////////////////////////////////
/// Get RTCM Frequency Ids
///
/// Inputs:
///   int       constell   Constellation
///   float     carrFreq   Carrier Frequency
///
/// Outputs:
///   int       idFreq     id Frequency
///////////////////////////////////////////////////////////////////////
function getRTCMFreqIds(constell, carrFreq) {
  ///////////////////////////////////////////////////////////////////////
  /// Variables
  ///////////////////////////////////////////////////////////////////////
  // TODO: Finish all constellations and signals
  let idFreq = 1;
  let type = 0;
  let iFreq = Math.round(carrFreq / 10.23e6);

  // Check type of frequency
  if (iFreq >= 154) {
    //QZSS L1 (154), GPS L1 (154), GAL E1 (154), and GLO L1 (156)
    type = 1;
  } else if (iFreq == 115) {
    //QZSS L5 (115), GPS L5 (115), GAL E5 (115)
    type = 5;
  } else if (iFreq == 153) {
    //BDS B1I (153)
    type = 2;
  }

  switch(constell) {
    case GPS:
      if (type == 1) {
        idFreq = 2;
      } else if (type == 5) {
        idFreq = 23;
      }
      break;
    case GLONASS:
      if (type == 1) {
        idFreq = 2;
      }
      break;
    case GALILEO:
      if (type == 1) {
        idFreq = 2;
      } else if (type == 5) {
        idFreq = 23;
      }
      break;
    case BEIDOU:
      if (type == 2) {
        idFreq = 2;
      } else if (type == 5) { //B2A Not available in RTCM3 RTKLib. Sent as B2I
        idFreq = 13;
      }
      break;
    default:
      break;
  }

  // Return Frequency ID
  return idFreq;
}

///////////////////////////////////////////////////////////////////////
/// Get formatted Date Time for file naming
///
/// Outputs:
///   String   filename          Filename in data formatted
///////////////////////////////////////////////////////////////////////
function getFormattedDateTime() {
  // Get date
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');
  const filename = year + month + day + hours + minutes + seconds;
  return filename;
}

///////////////////////////////////////////////////////////////////////
/// Generate Timestamp NMEA
///
/// Inputs:
///   String   msgPos            Message Position
///
/// Outputs:
///   String   nmeaMsg          NMEA Msg with timestamp
///////////////////////////////////////////////////////////////////////
function generateTimeStampNMEA(msgPos) {
  // Date now
  let now = new Date();

  // Format Time and Date
  let time = ('0' + now.getUTCHours()).slice(-2) +
    ('0' + now.getUTCMinutes()).slice(-2) +
    ('0' + now.getUTCSeconds()).slice(-2) + '.' +
    ('00' + now.getUTCMilliseconds()).slice(-3);

  let date = ('0' + now.getUTCDate()).slice(-2) +
    ('0' + (now.getUTCMonth() + 1)).slice(-2) +
    ('' + now.getUTCFullYear()).slice(-2);

  // Create NMEA msg
  let message = 'TIMEST,2,' + msgPos + ',' + date + ',' + time + ',S';

  // Generate checksum
  let checksum = 0;
  for (let i = 0; i < message.length; i++) {
    checksum ^= message.charCodeAt(i);
  }

  // Format checksum in hex
  let checksumHex = ('0' + checksum.toString(16).toUpperCase()).slice(-2);

  // Final msg
  let nmeaMsg = '$' + message + '*' + checksumHex;

  return nmeaMsg;
}

///////////////////////////////////////////////////////////////////////
/// Write Modified RTKLIB Config File
///
/// Inputs:
///   String   filename          Absolute name of file
///   Int      portTCP           Sending port
///   Int      portTCPRec        Reading port
///   String   folderName        Scenario Folder
///   JSON     content           RTKLIB parameters from app
///
///////////////////////////////////////////////////////////////////////
function writeConfigFile(filename, portTCP, portTCPRec, folderName, content) {
  // TODO: Finish Config from app
  // Extract config values
  let solType = content["solType"].toString();
  let freqType = content["freqType"].toString();
  let elevMask = (content["elevMask"] * Math.PI / 180.0).toString();
  let constType = content["constType"].toString();
  let logOutECEF = folderName + "/sol_" + getFormattedDateTime() + ".txt";
  let logFileRTCM3 = folderName + "/rtcm3_" + getFormattedDateTime() + ".log";

  let config = "[mapopt]\n" +
  "nmappnt=0\n" +
  "\n" +
  "[navi]\n" +
  "\n" +
  "[prcopt]\n" +
  "baseline1=0\n" +
  "baseline2=0\n" +
  "baselinec=0\n" +
  "bdsmodear=0\n" +
  "dynamics=0\n" +
  "elmaskar=0\n" +
  "elmaskhold=0\n" +
  "elmin="+elevMask+"\n" +
  "ephopt=0\n" +
  "eratio0=100\n" +
  "eratio1=100\n" +
  "err1=0.003\n" +
  "err2=0.003\n" +
  "err3=0\n" +
  "err4=1\n" +
  "exsats=\n" +
  "glomodear=0\n" +
  "initrst=1\n" +
  "ionoopt=1\n" +
  "maxaveep=3600\n" +
  "maxgdop=30\n" +
  "maxinno=30\n" +
  "maxout=5\n" +
  "maxtdiff=30\n" +
  "minfix=10\n" +
  "minlock=0\n" +
  "mode="+solType+"\n" +
  "modear=1\n" +
  "navsys="+constType+"\n" +
  "nf="+freqType+"\n" +
  "niter=1\n" +
  "outsingle=0\n" +
  "posopt1=0\n" +
  "posopt2=0\n" +
  "posopt3=0\n" +
  "posopt4=0\n" +
  "posopt5=0\n" +
  "posopt6=0\n" +
  "prn0=0.0001\n" +
  "prn1=0.001\n" +
  "prn2=0.0001\n" +
  "prn3=10\n" +
  "prn4=10\n" +
  "sclkstab=5e-12\n" +
  "snrmask_1_1=0\n" +
  "snrmask_1_2=0\n" +
  "snrmask_1_3=0\n" +
  "snrmask_1_4=0\n" +
  "snrmask_1_5=0\n" +
  "snrmask_1_6=0\n" +
  "snrmask_1_7=0\n" +
  "snrmask_1_8=0\n" +
  "snrmask_1_9=0\n" +
  "snrmask_2_1=0\n" +
  "snrmask_2_2=0\n" +
  "snrmask_2_3=0\n" +
  "snrmask_2_4=0\n" +
  "snrmask_2_5=0\n" +
  "snrmask_2_6=0\n" +
  "snrmask_2_7=0\n" +
  "snrmask_2_8=0\n" +
  "snrmask_2_9=0\n" +
  "snrmask_3_1=0\n" +
  "snrmask_3_2=0\n" +
  "snrmask_3_3=0\n" +
  "snrmask_3_4=0\n" +
  "snrmask_3_5=0\n" +
  "snrmask_3_6=0\n" +
  "snrmask_3_7=0\n" +
  "snrmask_3_8=0\n" +
  "snrmask_3_9=0\n" +
  "snrmask_4_1=0\n" +
  "snrmask_4_2=0\n" +
  "snrmask_4_3=0\n" +
  "snrmask_4_4=0\n" +
  "snrmask_4_5=0\n" +
  "snrmask_4_6=0\n" +
  "snrmask_4_7=0\n" +
  "snrmask_4_8=0\n" +
  "snrmask_4_9=0\n" +
  "snrmask_5_1=0\n" +
  "snrmask_5_2=0\n" +
  "snrmask_5_3=0\n" +
  "snrmask_5_4=0\n" +
  "snrmask_5_5=0\n" +
  "snrmask_5_6=0\n" +
  "snrmask_5_7=0\n" +
  "snrmask_5_8=0\n" +
  "snrmask_5_9=0\n" +
  "snrmask_ena1=0\n" +
  "snrmask_ena2=0\n" +
  "syncsol=0\n" +
  "thresar=3\n" +
  "thresslip=0.05\n" +
  "tidecorr=0\n" +
  "tropopt=1\n" +
  "\n" +
  "[serial]\n" +
  "cmd_0_0=\n" +
  "cmd_0_1=\n" +
  "cmd_0_2=\n" +
  "cmd_1_0=\n" +
  "cmd_1_1=\n" +
  "cmd_1_2=\n" +
  "cmd_2_0=\n" +
  "cmd_2_1=\n" +
  "cmd_2_2=\n" +
  "cmdena_0_0=0\n" +
  "cmdena_0_1=0\n" +
  "cmdena_0_2=0\n" +
  "cmdena_1_0=0\n" +
  "cmdena_1_1=0\n" +
  "cmdena_1_2=0\n" +
  "cmdena_2_0=0\n" +
  "cmdena_2_1=0\n" +
  "cmdena_2_2=0\n" +
  "\n" +
  "[setting]\n" +
  "antpcvfile=\n" +
  "blmode1=0\n" +
  "blmode2=0\n" +
  "blmode3=0\n" +
  "blmode4=0\n" +
  "dcbfile=\n" +
  "debugstatus=0\n" +
  "debugtrace=0\n" +
  "dgpscorr=0\n" +
  "eopfile=\n" +
  "freqtype1=0\n" +
  "freqtype2=0\n" +
  "freqtype3=0\n" +
  "freqtype4=0\n" +
  "fswapmargin=30\n" +
  "geoiddatafile=\n" +
  "intime64bit=0\n" +
  "intimespeed=x1\n" +
  "intimestart=0\n" +
  "intimetag=0\n" +
  "localdirectory=C:\\Temp\n" +
  "logappend=0\n" +
  "logswapinterval=\n" +
  "logtimetag=0\n" +
  "markercomment=\n" +
  "markername=\n" +
  "maxbl=10\n" +
  "moniport=52001\n" +
  "navselect=0\n" +
  "nmeacycle=5000\n" +
  "nmeapos1=0\n" +
  "nmeapos2=0\n" +
  "nmeapos3=0\n" +
  "nmeareq=0\n" +
  "outappend=0\n" +
  "outswapinterval=\n" +
  "outtimetag=0\n" +
  "panelfontbold=false\n" +
  "panelfontname=Ubuntu\n" +
  "panelfontsize=11\n" +
  "panelmode=2\n" +
  "panelstack=0\n" +
  "pane%F6fontitalic=false\n" +
  "plottype=0\n" +
  "plottype2=0\n" +
  "plottype3=0\n" +
  "plottype4=0\n" +
  "posfontbold=false\n" +
  "posfontitalic=false\n" +
  "posfontname=Ubuntu\n" +
  "posfontsize=11\n" +
  "proxyaddr=\n" +
  "recontime=10000\n" +
  "refant=\n" +
  "refantdel_0=0\n" +
  "refantdel_1=0\n" +
  "refantdel_2=0\n" +
  "refantpcv=0\n" +
  "refpos_0=3.932708098233048e-12\n" +
  "refpos_1=0\n" +
  "refpos_2=21384.685745179653\n" +
  "refpostype=0\n" +
  "resetcmd=\n" +
  "rovant=\n" +
  "rovantdel_0=0\n" +
  "rovantdel_1=0\n" +
  "rovantdel_2=0\n" +
  "rovantpcv=0\n" +
  "rovpos_0=3.932708098233048e-12\n" +
  "rovpos_1=0\n" +
  "rovpos_2=21384.685745179653\n" +
  "rovpostype=0\n" +
  "satpcvfile=\n" +
  "savedsol=100\n" +
  "sbascorr=0\n" +
  "sbassat=0\n" +
  "solbuffsize=1000\n" +
  "soltype=0\n" +
  "staposfile=\n" +
  "svrbuffsize=32768\n" +
  "svrcycle=10\n" +
  "timeouttime=10000\n" +
  "timesys=0\n" +
  "trkscale1=5\n" +
  "trkscale2=5\n" +
  "trkscale3=5\n" +
  "trkscale4=5\n" +
  "trktype1=0\n" +
  "trktype2=0\n" +
  "trktype3=0\n" +
  "trktype4=0\n" +
  "\n" +
  "[solopt]\n" +
  "datum=0\n" +
  "degf=0\n" +
  "geoid=0\n" +
  "height=0\n" +
  "maxsolstd=0\n" +
  "nmeaintv1=0\n" +
  "nmeaintv2=0\n" +
  "outhead=0\n" +
  "outopt=0\n" +
  "outvel=0\n" +
  "posf=0\n" +
  "sep=\n" +
  "timef=1\n" +
  "times=0\n" +
  "timeu=3\n" +
  "\n" +
  "[stream]\n" +
  "format0=1\n" +
  "format1=0\n" +
  "format2=3\n" +
  "format3=1\n" +
  "format4=0\n" +
  "format5=0\n" +
  "format6=0\n" +
  "format7=0\n" +
  "path_0_0=\n" +
  "path_0_1=:@:" + portTCP + "/:\n" +
  "path_0_2=::x1\n" +
  "path_0_3=\n" +
  "path_1_0=\n" +
  "path_1_1=\n" +
  "path_1_2=::x1\n" +
  "path_1_3=\n" +
  "path_2_0=\n" +
  "path_2_1=:@:" + portTCPRec + "/:\n" +
  "path_2_2=\n" +
  "path_2_3=\n" +
  "path_3_0=\n" +
  "path_3_1=:@:" + portTCPRec + "/:\n" +
  "path_3_2=" + logOutECEF + "\n" +
  "path_3_3=\n" +
  "path_4_0=\n" +
  "path_4_1=\n" +
  "path_4_2=" + logFileRTCM3 + "\n" +
  "path_4_3=\n" +
  "path_5_0=\n" +
  "path_5_1=\n" +
  "path_5_2=\n" +
  "path_5_3=\n" +
  "path_6_0=\n" +
  "path_6_1=\n" +
  "path_6_2=::x1\n" +
  "path_6_3=\n" +
  "path_7_0=\n" +
  "path_7_1=\n" +
  "path_7_2=\n" +
  "path_7_3=\n" +
  "rcvopt1=\n" +
  "rcvopt2=\n" +
  "rcvopt3=\n" +
  "stream0=2\n" +
  "stream1=0\n" +
  "stream2=2\n" +
  "stream3=5\n" +
  "stream4=5\n" +
  "stream5=0\n" +
  "stream6=0\n" +
  "stream7=0\n" +
  "streamc0=1\n" +
  "streamc1=0\n" +
  "streamc2=1\n" +
  "streamc3=1\n" +
  "streamc4=1\n" +
  "streamc5=0\n" +
  "streamc6=0\n" +
  "streamc7=0\n" +
  "\n" +
  "[tcpip]\n" +
  "cmd_0_0=\n" +
  "cmd_0_1=\n" +
  "cmd_0_2=\n" +
  "cmd_1_0=\n" +
  "cmd_1_1=\n" +
  "cmd_1_2=\n" +
  "cmd_2_0=\n" +
  "cmd_2_1=\n" +
  "cmd_2_2=\n" +
  "cmdena_0_0=0\n" +
  "cmdena_0_1=0\n" +
  "cmdena_0_2=0\n" +
  "cmdena_1_0=0\n" +
  "cmdena_1_1=0\n" +
  "cmdena_1_2=0\n" +
  "cmdena_2_0=0\n" +
  "cmdena_2_1=0\n" +
  "cmdena_2_2=0\n" +
  "\n" +
  "[tcpopt]\n" +
  "history0=\n" +
  "history1=\n" +
  "history2=\n" +
  "history3=\n" +
  "history4=\n" +
  "history5=\n" +
  "history6=\n" +
  "history7=\n" +
  "history8=\n" +
  "history9=\n" +
  "\n" +
  "[viewer]\n" +
  "color1=-16777214\n" +
  "color2=-16777213\n" +
  "fontname=Courier New\n" +
  "fontsize=9\n" +
  "\n" +
  "[window]\n" +
  "height=746\n" +
  "splitpos='@ByteArray(\\0\\0\\0\\xff\\0\\0\\0\\x1\\0\\0\\0\\x5\\0\\0\\x1\\x39\\0\\0\\x3(\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\0\\x1\\xff\\xff\\xff\\xff\\x1\\0\\0\\0\\x1\\0)\n" +
  "width=1143\n";

  fs.writeFile(filename, config, err => {
    if (err) {
      console.error(err);
    }
  });
}