const std = @import("std");

const math = @import("math.zig");

pub fn bufferedPrint() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try stdout.print("3 + 7 = {}\n", .{math.add(3, 7)});

    try stdout.flush(); // Don't forget to flush!
}

test {
    std.testing.refAllDecls(@This());
}
