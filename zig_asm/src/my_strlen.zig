const std = @import("std");

const strlib = @cImport({
    @cInclude("my_strlen.h");
});

pub const my_strlen = strlib.my_strlen;

test "test assembler" {
    try std.testing.expect(strlib.my_strlen("hello") == 5);
}
