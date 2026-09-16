const std = @import("std");

const math = @import("math");

pub export fn sayHello(num: i32) callconv(.c) i32 {
    return math.add(num, 42);
}

test "sayHello" {
    try std.testing.expectEqual(sayHello(42), 84);
}
