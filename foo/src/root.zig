const std = @import("std");
const Io = std.Io;

const math = @import("math");

pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn doSomeMath(num: i32, other: i32) void {
    std.debug.print("add({}, {}) => {}", .{ num, other, math.add(num, other) });
}

test {
    std.testing.refAllDecls(@This());
}
