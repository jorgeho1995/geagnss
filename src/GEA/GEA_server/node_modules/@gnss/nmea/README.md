# NMEA-0183 Decoder/Encoder
Decoder/encoder for NMEA-0183 message types.

## Installing

```
npm install -S @gnss/nmea
```

## Basic Usage
#### Decoding
```typescript
let buffer: string = ...; // String containing NMEA sentence
let message: NmeaMessage = NmeaTransport.decode(buffer);
```

#### Encoding
```typescript
let message = ...; // Message to be encoded
let buffer: string = NmeaTransport.encode(message);
```

### Creating
Messages can be manually constructed using `NmeaMessage???.construct({})`, which requires all message properties to be provided.
```typescript
NmeaMessageGga.construct({
    talker: NmeaTalker.NAV_SYSTEM_GNSS,
    time: new Date(0, 0, 0, 1, 2, 3, 0),
    latitude: 66.66,
    longitude: 33.33,
    quality: NmeaFixQuality.SIMULATOR,
    numberSatellites: 10,
    hdop: 2.5,
    altitude: 180.00,
    geoidalSeparation: 90.00,
    differentialAge: 5,
    differentialStationId: 'differentialStationId',
})
```

### Streams
Transform streams to convert from `NmeaMessage`s to sentence strings and vice-versa.
```typescript
let input: stream.Readable = ...;
let output: stream.Writable = ...;
input                                      // Stream of sentence strings
    .pipe(new NmeaDecodeTransformStream()) // Stream of NmeaMessage objects
    .pipe(new NmeaEncodeTransformStream()) // Stream of (identical) sentence strings
    .pipe(output);
```

`NmeaDecodeTransformStream` can optionally synchronize with the data stream e.g. if it starts receiving data from the middle of a message.

## Messages Supported
- **DTM** (_NmeaMessageDtm_)
- **GBS** (_NmeaMessageGbs_)
- **GGA** (_NmeaMessageGga_)
- **GLL** (_NmeaMessageGll_)
- **GNS** (_NmeaMessageGns_)
- **GRS** (_NmeaMessageGrs_)
- **GSA** (_NmeaMessageGsa_)
- **GST** (_NmeaMessageGst_)
- **GSV** (_NmeaMessageGsv_)
- **RMC** (_NmeaMessageRmc_)
- **THS** (_NmeaMessageThs_)
- **TXT** (_NmeaMessageTxt_)
- **VHW** (_NmeaMessageVhw_)
- **VLW** (_NmeaMessageVlw_)
- **VPW** (_NmeaMessageVpw_)
- **VTG** (_NmeaMessageVtg_)
- **ZDA** (_NmeaMessageZda_)

## Testing
`npm test`

## License
GPLv3

## Contributions
Contributions of new sentence types, bug fixes and general improvements via pull requests are welcome. Please ensure that code style matches that of the existing files.  