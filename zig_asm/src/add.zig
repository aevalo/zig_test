const std = @import("std");

const addlib = @cImport({
    @cInclude("add.h");
});

pub const add = addlib.add;

test "test adding" {
    try std.testing.expect(addlib.add(3, 7) == 10);
}
