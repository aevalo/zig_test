const std = @import("std");

const mydynlib = @import("mydynlib");

pub export fn sayHello(num: i32) void {
    std.debug.print("Got num {}", .{num});
}
