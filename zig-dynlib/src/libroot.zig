const std = @import("std");

pub export fn add(a: i32, b: i32) i32 {
    std.debug.print("Adding {} and {}\n", .{ a, b });
    return a + b;
}

pub export fn sub(a: i32, b: i32) i32 {
    return a - b;
}

pub export fn mul(a: i32, b: i32) i32 {
    return a * b;
}

pub export fn div(a: i32, b: i32) f32 {
    const af: f32 = @floatFromInt(a);
    const bf: f32 = @floatFromInt(b);
    return af / bf;
}

test "basic add functionality" {
    try std.testing.expectEqual(add(3, 7), 10);
}

test "basic sub functionality" {
    try std.testing.expectEqual(sub(3, 7), -4);
}

test "basic mul functionality" {
    try std.testing.expectEqual(mul(3, 7), 21);
}

test "basic div functionality" {
    try std.testing.expectEqual(div(3, 7), 0.42857143);
}
