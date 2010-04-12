

-- bcrc - binding to boost/crc, a generic CRC library.

For details on the meaning of bcrc.new() arguments, see the boost documentation
at <http://www.boost.org/doc/libs/1_34_1/libs/crc/crc.html>.

The builtin CRC types such as bcrc.crc16() use specialized implementations that
may have higher performance than those created by bcrc.new().

Also, note that process_bit() isn't supported by the optimal implementations,
which makes it a bit harder to support, so I only supported byte-wise CRCs.

Parameterizations of a number of CRC algorithms are described at
<http://regregex.bbcmicro.net/crc-catalogue.htm>. The relationship
between the catalogue's parameter names and the bcrc.new() arguments
are:

    Width  -> bits
    Poly   -> poly
    Init   -> initial
    XorOut -> xor
    RefIn  -> reflect_input
    RefOut -> reflect_output

- crc = bcrc.new(bits, poly[, initial, xor, reflect_input, reflect_remainder])

Mandatory args:

  - bits=n, where n is 8, 16, 24, 32
  - poly=n, where n is the polynomial

Optional args:

  - initial=n, where n is the initial value for the crc, defaults to 0
  - xor=n, where n is the value to xor with the final value, defaults to 0
  - reflect_input=bool, defaults to false
  - reflect_remainder=bool, defaults to false

Returns a crc object.

- crc = bcrc.crc16()

An optimal implementation of bcrc.new(16, 0x8005, 0, 0, true, true).

- crc = bcrc.ccitt()

An optimal implementation of bcrc.new(16, 0x1021, 0xFFFF, 0, false, false).

- crc = bcrc.xmodem()

An optimal implementation of bcrc.new(16, 0x8408, 0, 0, true, true).

- crc = bcrc.crc32()

An optimal implementation of bcrc.new(32, 0x04C11DB7, 0xFFFFFFFF, 0xFFFFFFFF, true, true).

- self = crc:reset()

Resets the crc to it's initial state.

Returns the crc object.

- self = crc:process(bytes, [start, [, end]])

Process substring of bytes from start..end.

If end is absent, it defaults to -1, the end of the bytes.
If start is absent, it defaults to 1, the start of the bytes.

Returns the crc object.

- checksum = crc:checksum()

Returns the current crc checksum (it is possible to keep calling process()
after this).

- checksum = crc(bytes, ...)

Checksum in a single call, so

  checksum = crc(bytes, start, end)

is a short form for

  checksum = crc:reset():process(bytes, start, end):checksum()

See crc:process() for a description of bytes, start, end, and their default values.
