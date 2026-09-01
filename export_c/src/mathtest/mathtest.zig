const std = @import("std");

pub export fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub export fn sayHello(num: i32) void {
    std.debug.print("Got num {}\n", .{num});
}

test "basic add functionality" {
    try std.testing.expectEqual(add(3, 7), 10);
}
