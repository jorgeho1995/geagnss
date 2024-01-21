# @ntrip/bit-buffer
Modification of the original [bit-buffer](https://www.npmjs.com/package/bit-buffer) by [inolen](https://github.com/inolen/bit-buffer), changing to TypeScript and modifying methods relating to buffer/string reading/writing.

BitBuffer provides two objects, BitView and BitStream. BitView is a wrapper for ArrayBuffers with support for bit-level reads and writes. BitStream is a wrapper for a BitView used to help maintain your current buffer position.

## Class: BitView

Wrapper for `ArrayBuffer`s with support for bit-level reads and writes.

Similar to JavaScript's [DataView](https://developer.mozilla.org/en-US/docs/JavaScript/Typed_arrays/DataView).

### Constructors

####  constructor

\+ **new BitView**(`buffer`: Uint8Array, `byteOffset`: number, `byteLength`: number): *[BitView](#classesbitviewmd)*

**Parameters:**

Name | Type | Default |
------ | ------ | ------ |
`buffer` | Uint8Array | - |
`byteOffset` | number | 0 |
`byteLength` | number | buffer.length - byteOffset |

**Returns:** *[BitView](#classesbitviewmd)*

### Properties

#### `Readonly` bitLength: *number*

Length of this view (in bits) from the start of its buffer.

___

#### `Readonly` buffer: *Uint8Array*

Underlying buffer which this view accesses.

___

#### `Readonly` byteLength: *number*

Length of this view (in bytes) from the start of its buffer.

### Methods

####  getBit(`offset`: number): *1 | 0*

Returns the bit value at the specified bit offset.

___

####  getBits(`offset`: number, `bits`: number, `signed`: boolean): *number*

Returns a `bits` long value at the specified bit offset.

___

####  getBitArray(`offset`: number, `bits`: number): *boolean[]*

Returns a `bits` long array of bit values at the specified bit offset.

___

####  readBuffer(`offset`: number, `byteLength`: number): *Uint8Array*

Returns a buffer containing the bytes at the specified bit offset.

___

####  readString(`offset`: number, `byteLength`: number, `decoder?`: undefined | TextDecoder): *string*

Returns a string decoded from the bytes at the specified bit offset.

___

####  setBit(`offset`: number, `value`: 1 | 0): *void*

Writes the bit value at the specified bit offset.

___

####  setBits(`offset`: number, `value`: number, `bits`: number): *void*

Writes a `bits` long value at the specified bit offset.

**`remarks`** There is no difference between signed and unsigned values when storing.

___

####  setBitArray(`offset`: number, `value`: boolean[], `bits`: number): *void*

Writes a `bits` long array of bit values at the specified bit offset.

___

####  writeBuffer(`offset`: number, `buffer`: Uint8Array): *number*

Writes the contents of a buffer at the specified bit offset.

**Returns:** The number of bytes written.

___

####  writeString(`offset`: number, `string`: string, `byteLength?`: undefined | number, `encoder?`: undefined | TextEncoder): *number*

Writes an encoded form of a string to the bytes at the specified bit offset.

**`remarks`** If the encoded string length is less than `byteLength`, the remainder is filled with `0`s.

**`remarks`** If the encoded string length is longer than `byteLength`, it is truncated.

**Returns:** The number of bytes written (may be different from the string length).

___

####  getBoolean, getInt8, getInt16, getInt32, getUint8, getUint16, getUint32, setBoolean, setInt8, setInt16, setInt32, setUint8, setUint16, setUint32

Helper methods, see `getBits` and `setBits`.


## Class: BitStream

Wrapper for [BitView](#classesbitviewmd)s that maintains an index while reading/writing sequential data.

### Constructors

####  constructor

\+ **new BitStream**(`source`: [BitView](#classesbitviewmd)): *[BitStream](#classesbitstreammd)*

**Parameters:**

Name | Type |
------ | ------ |
`source` | [BitView](#classesbitviewmd) |

**Returns:** *[BitStream](#classesbitstreammd)*

\+ **new BitStream**(`source`: Buffer, `byteOffset?`: undefined | number, `byteLength?`: undefined | number): *[BitStream](#classesbitstreammd)*

**Parameters:**

Name | Type |
------ | ------ |
`source` | Buffer |
`byteOffset?` | undefined &#124; number |
`byteLength?` | undefined &#124; number |

**Returns:** *[BitStream](#classesbitstreammd)*

### Properties

####  bitIndex: *number*

Current position of this stream (in bits) from/to which data is read/written.

___

#### `Readonly` bitLength: *number*

Length of this stream (in bits) from the start of its buffer.

___

#### `Readonly` buffer: *Uint8Array*

Underlying buffer which this stream accesses.

___

#### `Readonly` byteLength: *number*

Length of this stream (in bytes) from the start of its buffer.

___

#### `Readonly` view: *[BitView](#classesbitviewmd)*

Underlying view which this stream accesses.

### Accessors

####  bitsLeft

• **get bitsLeft**(): *number*

Number of bits remaining in this stream's underlying buffer from the current position.

**Returns:** *number*

___

####  byteIndex

• **get byteIndex**(): *number*

Current position of this stream (in bytes) from/to which data is read/written.

**Returns:** *number*

• **set byteIndex**(`val`: number): *void*

Current position of this stream (in bytes) from/to which data is read/written.

**Parameters:**

Name | Type |
------ | ------ |
`val` | number |

**Returns:** *void*

___

####  index

Alias for [bitIndex](#bitindex)

**Parameters:**

Name | Type |
------ | ------ |
`val` | number |

**Returns:** *void*

### Methods

####  readBit(): *1 | 0*

___

####  readBits(`bits`: number, `signed`: boolean): *number*

___

####  readBitArray(`bits`: number): *boolean[]*

___

####  readBuffer(`byteLength`: number): *Uint8Array*

___

####  readString(`byteLength`: number, `decoder?`: undefined | TextDecoder): *string*

___

####  writeBit(`value`: 1 | 0): *void*

___

####  writeBits(`value`: number, `bits`: number): *void*

___

####  writeBitArray(`value`: boolean[], `bits`: number): *void*

___

####  writeBuffer(`buffer`: Uint8Array): *number*

___

####  writeString(`string`: string, `byteLength?`: undefined | number, `encoder?`: undefined | TextEncoder): *number*

___

####  readBoolean, readInt8, readInt16, readInt32, readUint8, readUint16, readUint32, writeBoolean, writeInt8, writeInt16, writeInt32, writeUint8, writeUint16, writeUint32

Helper methods, see `readBits` and `writeBits`.
