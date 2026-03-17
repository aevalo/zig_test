const std = @import("std");

const addlib = @cImport({
    @cInclude("add.h");
});
const hellolib = @cImport({
    @cInclude("hello.h");
});
const strlib = @cImport({
    @cInclude("my_strlen.h");
});

pub const add = addlib.add;
pub const hello_world = hellolib.hello_world;
pub const my_strlen = strlib.my_strlen;

test "test adding" {
    try std.testing.expect(addlib.add(3, 7) == 10);
}

test "test assembler" {
    try std.testing.expect(strlib.my_strlen("hello") == 5);
}
