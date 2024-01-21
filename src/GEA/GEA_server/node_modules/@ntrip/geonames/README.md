# GeoNames.org Data File Parser
Helper class to read [GeoNames](http://geonames.org) data files with 0 dependencies.

```typescript
import {GeoNames} from 'geonames';
```

## GeoNames
```typescript
const geoNames = new GeoNames('path/to/geonames.txt');
```

### Methods
##### async *geoNames\[Symbol.asyncIterator\]()
Generator function to get list of places found in the data file without loading all into memory at once.
```typescript
for await (let place: Place of geoNames) {
    console.log(place.name);
}
```

##### geoNames.stream()

##### geoNames.nearest(to: {latitude: number, longitude: number})
Finds the place nearest to the location provided, without loading all places into memory.
```typescript
let nearest = geoNames.nearest({latitude: 53.33, longitude: -6.24});
console.log(`${nearest.name}, ${nearest.countryCode}`) // Dublin, IE
```

## Place
```typescript
class Place {
    id: number;

    name: string;
    asciiName: string;
    alternativeNames: string[];

    latitude: number;
    longitude: number;

    featureClass: string;
    featureCode: string;

    countryCode: string;
    alternativeCountryCode: string;

    adminCode1: string;
    adminCode2: string;
    adminCode3: string;
    adminCode4: string;

    population: number;

    elevation: number;
    digitalElevationModel: number;

    timezone: string;
    modificationDate: Date;

    // Distance of place provided location 
    distance(to: {latitude: number, longitude: number}): number;
}
```