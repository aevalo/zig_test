const std = @import("std");
const Io = std.Io;

const clap = @import("clap");
const signals = @import("signals");

var should_stop = std.atomic.Value(bool).init(false);

extern "c" fn strerror(errnum: c_int) [*:0]const u8;

fn usrHandler(sig: std.posix.SIG) callconv(.c) void {
    if (sig == std.posix.SIG.USR1) {
        std.debug.print("USR1", .{});
    } else if (sig == std.posix.SIG.USR2) {
        std.debug.print("USR2", .{});
    } else if (sig == std.posix.SIG.INT) {
        std.debug.print("INT", .{});
        should_stop.store(true, .monotonic);
    } else if (sig == std.posix.SIG.TERM) {
        std.debug.print("TERM", .{});
        should_stop.store(true, .monotonic);
    }
}

pub fn main(init: std.process.Init) !void {
    var sa: std.posix.Sigaction = .{
        .handler = .{ .handler = usrHandler },
        .mask = std.posix.sigemptyset(),
        .flags = std.posix.SA.RESTART,
    };
    std.posix.sigaction(std.posix.SIG.USR1, &sa, null);
    std.posix.sigaction(std.posix.SIG.USR2, &sa, null);
    std.posix.sigaction(std.posix.SIG.INT, &sa, null);
    std.posix.sigaction(std.posix.SIG.TERM, &sa, null);

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-d, --daemonize        Daemonize the process.
        \\-t, --daemon-type <DAEMONTYPE>        Daemonize the process.
    );

    // Declare our own parsers which are used to map the argument strings to other
    // types.
    const DaemonType = enum { sysv, newstyle };
    const parsers = comptime .{
        .DAEMONTYPE = clap.parsers.enumeration(DaemonType),
    };

    // Initialize our diagnostics, which can be used for reporting useful errors.
    // This is optional. You can also pass `.{}` to `clap.parse` if you don't
    // care about the extra information `Diagnostics` provides.
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, init.minimal.args, .{
        .diagnostic = &diag,
        .allocator = init.gpa,
    }) catch |err| {
        // Report useful error and exit.
        try diag.reportToFile(init.io, .stderr(), err);
        return clap.usageToFile(init.io, .stdout(), clap.Help, &params);
    };
    defer res.deinit();

    std.debug.print("{s}", .{strerror(0)});

    if (res.args.help != 0)
        return clap.helpToFile(init.io, .stderr(), clap.Help, &params, .{});
    if (res.args.daemonize != 0)
        std.debug.print("--daemonize\n", .{});

    const ret = std.c.fork();
    if (ret == 0) {
        while (!should_stop.load(.monotonic)) {}
    } else if (ret == -1) {
        std.debug.print("Fork failed: {s}", .{strerror(@intFromEnum(std.c.errno(ret)))});
    } else {
        std.debug.print("Child process ID: {}", .{ret});
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
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}
