require"lunit"
require"bcrc"

module("bcrc-test", lunit.testcase, package.seeall)

function _test_new(bits)
    local crc
    if type(bits) == "number" then
        crc = assert(bcrc.new(bits, 0x8005))
    else
        crc = assert(bcrc[bits]())
    end
    assert(crc.reset)
    assert(crc.process)
    assert(crc.checksum)
end

function test_new()
    _test_new(8)
    _test_new(16)
    _test_new(24)
    _test_new(32)
    _test_new("crc16")
    _test_new("ccitt")
    _test_new("xmodem")
    _test_new("crc32")

    assert_error(function ()
        _test_new(0)
    end)
    assert_error(function ()
        _test_new(33)
    end)
end

function test_chaining()
    local crc = assert(bcrc.new(32, 0x8005))
    assert(crc:reset())
    assert(crc:reset():reset())
    assert(crc:process(""):process(""))
    assert(crc:checksum() == crc:checksum())
end

local function crc_bytes(crc, bytes)
    local sum1 = crc:reset():process(bytes):checksum()
    local sum2 = crc(bytes)
    local sum3 = crc:reset():process(bytes, 1, #bytes):checksum()
    local sum4 = crc(bytes, 1, -1)
    assert_equal(sum1, sum2, "operator(bytes) is correct")
    assert_equal(sum1, sum3, "process(bytes,start,end) is correct")
    assert_equal(sum3, sum4, "operator(bytes,start,end) is correct")

    return sum1
end

local function crc_assert(crc, bytes, expect)
    local got = crc_bytes(crc, bytes)
    local function hex(n) return string.format("%x", n) end
    assert_equal(hex(expect), hex(got), "expected crc")
end

function _test_crc32(crc)
    assert(crc)

    crc_assert(crc,
        string.char(0x05, 0x03, 0x00, 0x00, 0x03, 0x31, 0x00, 0x08), 
        636314603 --25ED63EB in big endian
        )
    crc_assert(crc,
        string.char(0x06, 0x03, 0x00, 0x00, 0x03, 0x30, 0x00, 0x14, 0x00, 0x00, 0x2f, 0x24, 0x49, 0x78, 0x32, 0xd9, 0x00, 0xac, 0xdc, 0x05),
        1908274416   --71BDF4F0 in big endian
        )
    crc_assert(crc,
        string.char(0x05, 0x03, 0x00, 0x00, 0x03, 0x3a, 0x00, 0x08),
        699960330 --29B88C0A
        )
    crc_assert(crc,
        "123456789",
        0xCBF43926
        )
end

function test_crc32_basic()
    _test_crc32(bcrc.new(32, 0x04c11db7, 0xFFFFFFFF, 0xFFFFFFFF, true, true))
end

function test_crc32_optimal()
    _test_crc32(bcrc.crc32())
end

function test_dnp3()
    -- From <http://regregex.bbcmicro.net/crc-catalogue.htm>:
    -- Name   : "CRC-16/DNP"
    -- Width  : 16
    -- Poly   : 3D65
    -- Init   : 0000
    -- RefIn  : True
    -- RefOut : True
    -- XorOut : FFFF
    -- Check  : EA82
    -- XCheck : 82EA
    --
    local crc = assert(bcrc.new(16, 0x3D65, 0, 0xffff, true, true))
    -- Test vectors from catalogue, "check":
    crc_assert(crc, "123456789", 0xEA82)
    -- Test vectors from data/Plugins/Grammar/dnp3dll-test:
    crc_assert(crc,
        string.char(0xc1, 0xc1, 0x00),
        0x24c5)
    crc_assert(crc,
        string.char(0x05, 0x64, 0x05, 0xF2, 0x01, 0x00, 0x00, 0x00),
        0x0c52)
    crc_assert(crc,
        string.char(0x05, 0x64, 0x14, 0xc4, 0x04, 0x00, 0x03, 0x00),
        0x17c7)
    crc_assert(crc,
        string.char(0xc1, 0xe1, 0x81, 0x90, 0x00, 0x20, 0x01, 0x17, 0x07, 0x00, 0x01, 0xc8, 0x00, 0x00, 0x00,
        0x01), 0x81da)
end

