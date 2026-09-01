const std = @import("std");
const testing = std.testing;

const zlib_sys = @cImport({
    @cInclude("zlib.h");
});

pub fn version() [*c]const u8 {
    return zlib_sys.zlibVersion();
}
