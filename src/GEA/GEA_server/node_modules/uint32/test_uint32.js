/* global describe, it, require, window */

if (typeof window === 'undefined') {
    var uint32 = require('./uint32.js');
    var expect = require('expect.js');
}

(function () {
    "use strict";

    function toHex (ui32) {
        var tmp = ui32.toString(16);
        var neededZeros = 8 - tmp.length;
        return new Array(neededZeros + 1).join('0') + tmp;
    }

    function expectHex (ui32) {
        return {
            to: {
                be: function (expected) {
                    expect(toHex(ui32)).to.be(toHex(expected));
                }
            }
        };
    }

    describe('Creating and Extracting', function () {
        describe('fromBytesBigEndian()', function () {
            it('should create an uint32 of given bytes', function () {
                expect(uint32.fromBytesBigEndian(1,2,3,4)).to.be(0x01020304);
            });
        });

        describe('getByteBigEndian()', function () {
            it('should extract the high byte', function () {
                expect(uint32.getByteBigEndian(0xf1f2f3f4, 0)).to.be(0xf1);
            });
            it('should extract the 2nd high byte', function () {
                expect(uint32.getByteBigEndian(0xf1f2f3f4, 1)).to.be(0xf2);
            });
            it('should extract the 3rd high byte', function () {
                expect(uint32.getByteBigEndian(0xf1f2f3f4, 2)).to.be(0xf3);
            });
            it('should extract the low byte', function () {
                expect(uint32.getByteBigEndian(0xf1f2f3f4, 3)).to.be(0xf4);
            });
        });

        describe('toHex()', function () {
            it('should fill with leading zeros', function () {
                expect(uint32.toHex(0x01)).to.be('00000001');
            });
            it('should use the optionalLength parameter', function () {
                expect(uint32.toHex(0x01, 2)).to.be('01');
            });
        });

        describe('toUint32()', function () {
            it('should convert an uint32 value', function () {
                expect(uint32.toUint32(0xf1f2f3f4)).to.be(0xf1f2f3f4);
            });
            it('should convert a negative value', function () {
                expect(uint32.toUint32( -1)).to.be(0xffffffff);
            });
            it('should convert a high value', function () {
                expect(uint32.toUint32(0x010000000004)).to.be(4);
            });
            it('should ignore values after decimal point', function () {
                expect(uint32.toUint32(3.5)).to.be(3);
            });
        });
    });

    describe('Bitwise Logical Operations', function () {
        describe('or()', function () {
            it('should handle low bits', function () {
                expect(uint32.or(1, 1)).to.be(1);
                expect(uint32.or(1, 0)).to.be(1);
                expect(uint32.or(1, 2)).to.be(3);
            });
            it('should handle high bits', function () {
                expect(uint32.or(0xffffffff, 0)).to.be(0xffffffff);
            });
            it('should handle more than two values', function () {
                expect(uint32.or(1, 2, 4)).to.be(7);
                expect(uint32.or(1, 2, 4, 8)).to.be(15);
            });
        });

        describe('and()', function () {
            it('should handle low bits', function () {
                expect(uint32.and(1, 1)).to.be(1);
                expect(uint32.and(1, 0)).to.be(0);
                expect(uint32.and(1, 2)).to.be(0);
            });
            it('should handle high bits', function () {
                expect(uint32.or(0xffffffff, 0xffffffff)).to.be(0xffffffff);
            });
            it('should handle more than two values', function () {
                expect(uint32.and(1, 3, 5)).to.be(1);
                expect(uint32.and(3, 11, 19, 35)).to.be(3);
            });
        });

        describe('xor()', function () {
            it('should xor high bit to off', function () {
                expect(uint32.xor(0x80000000, 0xffffffff)).to.be(0x7fffffff);
            });
            it('should xor high bit to on', function () {
                expect(uint32.xor(0x40000000, 0x80000000)).to.be(0xc0000000);
            });
            it('should xor more than two values', function () {
                expect(uint32.xor(1, 2, 4)).to.be(7);
                expect(uint32.xor(1, 3, 5)).to.be(7);
                expect(uint32.xor(1, 2, 4, 8)).to.be(15);
            });
        });

        describe('not()', function () {
            it('should negate 0', function () {
                expect(uint32.not(0)).to.be(0xffffffff);
            });
            it('should negate negative values', function () {
                expect(uint32.not( -1)).to.be(0);
            });
            it('should negate values with high bit set', function () {
                expect(uint32.not(0xc0000000)).to.be(0x3fffffff);
            });
        });
    });

    describe('Shifting and Rotating', function () {
        describe('shiftLeft()', function () {
            it('should handle the high bit', function () {
                expect(uint32.shiftLeft(3, 30)).to.be(0xc0000000);
                expect(uint32.shiftLeft(0x40000000, 1)).to.be(0x80000000);
                expect(uint32.shiftLeft(0x40000000, 2)).to.be(0);
                expect(uint32.shiftLeft(0x80000000, 1)).to.be(0);
            });
        });
        describe('shiftRight()', function () {
            it('should handle the high bit', function () {
                expect(uint32.shiftLeft(0x40000000, 1)).to.be(0x80000000);
                expect(uint32.shiftLeft(0x80000000, 1)).to.be(0);
            });
        });

        describe('rotateLeft()', function () {
            it('should rotate little values', function () {
                expect(uint32.rotateLeft(0x01, 1)).to.be(0x02);
                expect(uint32.rotateLeft(0x02, 1)).to.be(0x04);
            });
            it('should rotate big values', function () {
                expect(uint32.rotateLeft(0x40000000, 1)).to.be(0x80000000);
                expect(uint32.rotateLeft(0x80000000, 1)).to.be(0x00000001);
            });
        });

        describe('rotateRight()', function () {
            it('should rotate little values', function () {
                expect(uint32.rotateRight(0x01, 1)).to.be(0x80000000);
                expect(uint32.rotateRight(0x02, 1)).to.be(0x01);
            });
            it('should rotate big values', function () {
                expect(uint32.rotateRight(0x40000000, 1)).to.be(0x20000000);
                expect(uint32.rotateRight(0x80000000, 1)).to.be(0x40000000);
            });
        });
    });

    describe('Logical Gates', function () {
        describe('choose()', function () {

            it('should use y, if x flag is set', function () {
                expect(uint32.choose(1, 0, 0)).to.be(0);
                expect(uint32.choose(1, 0, 1)).to.be(0);
                expect(uint32.choose(1, 1, 0)).to.be(1);
                expect(uint32.choose(1, 1, 1)).to.be(1);

                expect(uint32.choose(0xffffffff,  0,  0)).to.be(0);
                expect(uint32.choose(0xffffffff,  0, 0xffffffff)).to.be(0);
                expect(uint32.choose(0xffffffff, 0xffffffff,  0)).to.be(0xffffffff);
                expect(uint32.choose(0xffffffff, 0xffffffff, 0xffffffff)).to.be(0xffffffff);
            });
            it('should use z, if x flag is not set', function () {
                expect(uint32.choose(0, 0, 0)).to.be(0);
                expect(uint32.choose(0, 0, 1)).to.be(1);
                expect(uint32.choose(0, 1, 0)).to.be(0);
                expect(uint32.choose(0, 1, 1)).to.be(1);

                expect(uint32.choose(0,  0,  0)).to.be(0);
                expect(uint32.choose(0,  0, 0xffffffff)).to.be(0xffffffff);
                expect(uint32.choose(0, 0xffffffff,  0)).to.be(0);
                expect(uint32.choose(0, 0xffffffff, 0xffffffff)).to.be(0xffffffff);
            });
            it('should use the proper y or z', function () {
                expect(uint32.choose(0x01010202, 0x00010001, 0x01000100)).to.be(0x00010100);
            });
        });
        describe('majority()', function () {
            it('should return 0, if all parameters are 0', function () {
                expect(uint32.majority(0, 0, 0)).to.be(0);
            });
            it('should return 0, if all but one parameters are 0', function () {
                expect(uint32.majority(0xffffffff, 0, 0)).to.be(0);
                expect(uint32.majority(0, 0xffffffff, 0)).to.be(0);
                expect(uint32.majority(0, 0, 0xffffffff)).to.be(0);
            });
            it('should return 0xffffffff, if two parameters are 0xffffffff', function () {
                expect(uint32.majority(0xffffffff, 0xffffffff, 0)).to.be(0xffffffff);
                expect(uint32.majority(0xffffffff, 0, 0xffffffff)).to.be(0xffffffff);
                expect(uint32.majority(0, 0xffffffff, 0xffffffff)).to.be(0xffffffff);
            });
            it('should return 0xffffffff, if all parameters are 0xffffffff', function () {
                expect(uint32.majority(0xffffffff, 0xffffffff, 0xffffffff)).to.be(0xffffffff);
            });
            it('should work bitwise', function () {
                // all above tests bitwise
                expect(uint32.majority(parseInt('01001101', 2), parseInt('00101011', 2), parseInt('00010111', 2))).to.be(parseInt('00001111', 2));
            });
        });
    });

    describe('Arithmetic', function () {
        describe('addMod32()', function () {
            it('should add values below 2^32', function () {
                expect(uint32.addMod32(0x40000000, 0x40000000)).to.be(0x80000000);
            });
            it('should add an arbitrary number of arguments', function () {
                expect(uint32.addMod32(1, 2, 3)).to.be(6);
                expect(uint32.addMod32(1, 2, 3, 4)).to.be(10);
                expect(uint32.addMod32(1, 2, 3, 4, 5)).to.be(15);
                expect(uint32.addMod32(1, 2, 3, 4, 5, 6)).to.be(21);
            });
            it('should add negative values', function () {
                expect(uint32.addMod32( -1, -1)).to.be(0xfffffffe);
            });
            it('should calc mod32', function () {
                expect(uint32.addMod32(0x80000001, 0x80000001)).to.be(2);
            });
        });
        describe('log2()', function () {
            it('should work for 0', function () {
                expect(uint32.log2(0)).to.be( -Infinity);
            });
            it('should work for 1', function () {
                expect(uint32.log2(1)).to.be(0);
            });
            it('should work for 2', function () {
                expect(uint32.log2(2)).to.be(1);
            });
            it('should work for values between 2 and 2^31', function () {
                for (var exp = 2; exp < 32; exp += 1) {
                    var pow = Math.pow(2, exp);
                    expect(uint32.log2(pow - 1)).to.be(exp - 1);
                    expect(uint32.log2(pow)).to.be(exp);
                }
            });
            it('should work for 2^32-1', function () {
                expect(uint32.log2(0xffffffff)).to.be(31);
            });
        });
        describe('mult()', function () {
            it('should work, if the product is less than 2^32', function () {
                var result = new Uint32Array(2);
                uint32.mult(0xffff, 0xffff, result);
                expect(result[0]).to.be(0);
                expect(result[1]).to.be(0xfffe0001);
            });
            it('should work, if the product is smaller than 2^52', function () {
                var result = new Uint32Array(2);
                uint32.mult(0x04000000, 0x03ffffff, result);
                expect(result[0]).to.be(0xfffff);
                expect(result[1]).to.be(0xfc000000);
            });
            it('should work, if the product is 2^52', function () {
                var result = new Uint32Array(2);
                uint32.mult(0x04000000, 0x04000000, result);
                expect(result[0]).to.be(0x00100000);
                expect(result[1]).to.be(0);
            });
            it('should work, if the product is greater than 2^52', function () {
                var result = new Uint32Array(2);
                uint32.mult(0xff030201, 0xff030201, result);
                expectHex(result[0]).to.be(0xfe06fe07);
                expectHex(result[1]).to.be(0x0a0a0401);

                uint32.mult(0xffffffff, 0xffffffff, result);
                expect(result[0]).to.be(0xfffffffe);
                expect(result[1]).to.be(1);

                // (2**15 + 1) ** 2 = 2**30 + 2 * 2**15 + 1 = 0x40 00 00 01 00 00 00 01
                uint32.mult(0x80000001, 0x80000001, result);
                expectHex(result[0]).to.be(0x40000001);
                expectHex(result[1]).to.be(0x00000001);
            });
            it('should not make the rounding error the 0.1.3 version did', function () {
                var result = new Uint32Array(2);
                uint32.mult(0xfa93896b, 0xa1a9f539, result);
                expectHex(result[1]).to.be(0xffffffd3);
                expectHex(result[0]).to.be(0x9e3d24d8);
            });
        });

    });

})();
