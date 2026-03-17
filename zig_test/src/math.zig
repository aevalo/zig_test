const std = @import("std");

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn sub(a: i32, b: i32) i32 {
    return _sub(a, b);
}

fn _sub(a: i32, b: i32) i32 {
    return a - b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}

test "basic sub functionality" {
    try std.testing.expect(sub(3, 7) == -4);
}

test "basic internal sub functionality" {
    try std.testing.expect(_sub(3, 7) == -4);
}
