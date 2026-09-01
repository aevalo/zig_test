const std = @import("std");

const zlib = @import("zlib");

pub fn main(init: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: std.Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    stdout_writer.print("Linked against zlib version {s}.\n", .{zlib.version()}) catch {
        std.debug.print("Failed to print to stdout", .{});
    };

    try stdout_writer.flush(); // Don't forget to flush!
}

test "simple test" {
    var list = try std.ArrayList(i32).initCapacity(std.testing.allocator, 3);
    defer list.deinit(std.testing.allocator); // try commenting this out and see if zig detects the memory leak!
    try list.append(std.testing.allocator, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
