<h1 align="center">raw_gnss 📡</h1></br>
<p align="center">
raw_gnss 📡 makes it easy to fetch raw GNSS data including GNSS Measurement Events, GNSS Navigation Messages, and GNSS Status Events.
</p>
<br>

## Get Raw GNSS Data On Android

Since Android 7.0, Android exposed the GNSS APIs required to get raw data points opening up the location black box earlier.

raw_gnss allows you to easily fetch the GNSSMeasurementEvents, GNSSNavigationMessages and GNSSStatus via inbuilt streams.

### Usage

*GNSS Measurements*

```dart
  RawGnss().gnssMeasurementEvents.listen((e) {});
```

*GNSS Navigation Messages*

```dart
  RawGnss().gnssNavigationMessageEvents.listen((e) {});
```
    
*GNSS Status*

```dart
  RawGnss().gnssStatusEvents.listen((e) {});
```

### Example: Fetch GNSSMeasurementModels
```dart
  StreamBuilder<GnssMeasurementModel>(
    builder: (context, snapshot) {
      if (snapshot.data == null) {
        return CircularProgressIndicator();
      }

      return ListView.builder(
          itemBuilder: (context, position) {
            return ListTile(
              title: Text(
                  "Satellite: ${snapshot.data!.measurements![position].svid}"),
            );
          },
          itemCount: snapshot.data!.measurements?.length ?? 0,
      );
    },
    stream: RawGnss().gnssMeasurementEvents,
  ),
```

iOS does not yet expose raw location data, hence this plugin does not support iOS as of yet.