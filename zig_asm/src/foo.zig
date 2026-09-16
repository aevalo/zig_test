const std = @import("std");

pub extern fn foo() callconv(.c) u32;

test {
    try std.testing.expect(foo() == 42);
}
