# http-parser-ts

This library is based on the original `http-parser-js` library by Tim Caswell (https://github.com/creationix/http-parser-js) but is rewritten in TypeScript to be easier to understand and extend.

# HTTP Parser

This library parses HTTP protocol for requests and responses. It was created to replace `http_parser.c` since calling C++ function from JS is really slow in V8. However, it is now primarily useful in having a more flexible/tolerant HTTP parser when dealing with legacy services that do not meet the strict HTTP parsing rules Node's parser follows.

This is packaged as a standalone npm module. To use in node, run HTTPParser.bind() before importing `http`.

```js
// Monkey patch before you require http for the first time
require('http-parser-ts').HTTPParser.bind();
// or ES6 module
import { HTTPParser } from 'http-parser-ts';
HTTPParser.bind();

let http = require('http');
// ...
```

## Status

This should now be usable in any node application, it now supports (nearly) everything `http_parser.c` does while still being tolerant with corrupted headers, and other kinds of malformed data.

### Node Versions

`http-parser-ts` should work via monkey-patching on Node v6-v11, and v13-v14.

Node v12.x renamed the internal http parser, and did not expose it for monkey-patching, so to be able to monkey-patch on Node v12, you must run `node --http-parser=legacy file.js` to opt in to the old, monkey-patchable http_parser binding.

## License

MIT. See LICENSE.md
