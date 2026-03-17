const std = @import("std");

const zig_asm = @import("zig_asm");

pub fn main() !void {
    // Initialize an allocator
    // Can be any one of them, this is the most basic one
    const allocator = std.heap.page_allocator;

    std.debug.print("3 + 7 = {d}\n", .{zig_asm.add(3, 7)});

    zig_asm.hello_world();

    // Initialize arguments
    // Then deinitialize at the end of scope
    var argsIterator = try std.process.ArgIterator.initWithAllocator(allocator);
    defer argsIterator.deinit();

    // Skip executable
    _ = argsIterator.next();

    // Handle cases accordingly
    if (argsIterator.next()) |arg| {
        std.debug.print("The length of \"{s}\" is {d}\n", .{ arg, zig_asm.my_strlen(arg) });
    } else {
        std.debug.print("Error: this program must have 1 command line argument\n", .{});
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
