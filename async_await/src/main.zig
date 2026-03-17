const std = @import("std");
const HostName = std.Io.net.HostName;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var io_impl: std.Io.Threaded = .init(allocator, .{ .environ = std.process.Environ.empty });
    defer io_impl.deinit();
    const io = io_impl.io();
    const host_name: HostName = try .init("example.com");

    // Run 3 requests concurrently
    var results: [3]usize = undefined;

    // Start all concurrent tasks
    var task1 = try io.concurrent(request_website, .{ allocator, io, host_name, 0, &results[0] });
    defer task1.cancel(io) catch {};

    var task2 = try io.concurrent(request_website, .{ allocator, io, host_name, 1, &results[1] });
    defer task2.cancel(io) catch {};

    var task3 = try io.concurrent(request_website, .{ allocator, io, host_name, 2, &results[2] });
    defer task3.cancel(io) catch {};

    // Wait for all tasks to complete
    try task1.await(io);
    try task2.await(io);
    try task3.await(io);

    std.log.info("All requests completed successfully!", .{});
    std.log.info("Results: {any}", .{results});
}

fn request_website(allocator: std.mem.Allocator, io: std.Io, host_name: HostName, index: usize, result: *usize) !void {
    var http_client: std.http.Client = .{ .allocator = allocator, .io = io };
    defer http_client.deinit();

    var request = try http_client.request(.HEAD, .{
        .scheme = "http",
        .host = .{ .percent_encoded = host_name.bytes },
        .port = 80,
        .path = .{ .percent_encoded = "/" },
    }, .{});
    defer request.deinit();

    try request.sendBodiless();

    var redirect_buffer: [1024]u8 = undefined;

    const response = try request.receiveHead(&redirect_buffer);
    std.log.info("Index {d} received {d} {s}", .{ index, response.head.status, response.head.reason });
    result.* = index;
}
