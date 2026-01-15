const std = @import("std");
const addlib = @cImport({
    @cInclude("add.h");
});
const strlib = @cImport({
    @cInclude("my_strlen.h");
});

pub const add = addlib.add;
pub const my_strlen = strlib.my_strlen;

test "test adding" {
    try std.testing.expect(addlib.add(3, 7) == 10);
}

test "test assembler" {
    try std.testing.expect(strlib.my_strlen("hello") == 5);
}
