const std = @import("std");
const testing = @import("testing");
const zbench = @import("zbench");

fn myBenchmark(allocator: std.mem.Allocator) void {
    // Code to benchmark here
    _ = allocator;
    for (0..5) |i| {
        _ = testing.add(@intCast(i), @intCast(i));
    }
}

pub fn main() !void {
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();
    try bench.add("My Benchmark", myBenchmark, .{});
    var buf: [1024]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&buf);
    const writer = &stdout.interface;
    try bench.run(writer);
    try writer.flush();
}
