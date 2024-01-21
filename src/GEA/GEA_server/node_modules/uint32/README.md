uint32
======

An uint32 library for javascript.
---------------------------------

WHAT??
------

Javascript has c like binary operators, but within c you normally use the operators on unsigned ints.
In javascript all operators work on SIGNED ints. So the operators do always a signed int conversion,
which may have some astonishing side effects:

```
    var x = 0xFFFFFFFF;
    ~~x === x;      // false! ~~x -> -1
    (x | 0) === x;  // false! x | 0 -> -1
    (x & x) === x;  // false! x & x -> -1
    (x ^ 0) === x;  // false! x ^ 0 -> -1
    (x >> 0) === x; // false! x >> 0 -> -1
    (x << 0) === x; // false! x << 0 -> -1
```

All these samples are clear counter examples of "Principle of Least Astonishment", see http://en.wikipedia.org/wiki/Principle_of_least_astonishment

If You ever wrote "/\*jshint bitwise:false\*/" (allowing bitwise operations),
You should know, when the above pitfalls happen.

Getting
-------

    npm install uint32
    
or building for your own
    
    git clone https://github.com/fxa/uint32.js.git
    cd uint32.js
    npm install
    npm test
    tests.html

Feel free to include uint32.js within your other js sources and minify it together with your code.
This library has only about 50 effective lines of code...
Feel free to copy&paste the code.
    
API
--- 
The API is very unspectacular. The main thing is, it works as you expect, and that is much more than you get calling javascript binary operators directly.

```
    //
    // importing
    // 
    
    // within node
    var uint32 = require('uint32');
    
    // within browser
    <script src="/path/to/uint32.js"></script>
    <script type="text/javascript">
        var uint32 = window.uint32;
    </script>

    // Creating and Extracting
    uint32.fromBytesBigEndian(1,2,3,4); // 0x01020304
    uint32.getByteBigEndian(0x01020304, 0); // 1
    uint32.toHex(1); // '00000001'
    uint32.toHex(1, 4); // '0001'
    uint32.toUint32(-1); // 0xffffffff
    uint32.highPart(0x0102030405); // 1
    
    // Bitwise Logical Operators    
    uint32.and(1, 3, 5); // 1    
    uint32.or(1, 3, 5); // 5
    uint32.xor(1, 3, 5); // 7
    uint32.not(1); // 0xfffffffe

    // Shifting and Rotating
    uint32.shiftLeft(0x40000000, 1); // 0x80000000
    uint32.shiftRight(0x80000000, 1); // 0x40000000
    uint32.rotateLeft(0x80000000, 1); // 0x00000001
    uint32.rotateRight(0x00000001, 1); // 0x80000000

    // Logical Gates     
    uint32.choose(0x01010202, 0x00010001, 0x01000100); // 0x00010100 
    uint32.majority (0x01, 0x00, 0x01); // 0x01

    // Arithmetic
    uint32.addMod32(0x80000001, 0x80000001); // 2
    uint32.log2(0xffffffff); // 31
    var result = new Uint32Array(2);
    uint32.mult(0xffffffff, 0xffffffff, result); // result -> [0xfffffffe, 0x00000001]
    
    // That's all! 
    // Detailed specifications are in the tests!
```

License
-------
Do, what You want.
This library was designed to be a copy/paste template.
It would be nice to hear from You, if You used this library or if You just copy/pasted some source.
It would be nice, if you added a "contains code of Franz X Antesberger" or something like that or a ref to the github project
to your license information or elsewhere.
