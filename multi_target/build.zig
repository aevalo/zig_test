const std = @import("std");

const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

pub fn build(b: *std.Build) void {
    for (targets) |t| {
        const exe = b.addExecutable(.{
            .name = "hello",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/hello.zig"),
                .target = b.resolveTargetQuery(t),
                .optimize = .ReleaseSafe,
            }),
        });

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = t.zigTriple(b.allocator) catch blk: {
                        _ = b.addFail("Failed to parse executable version");
                        break :blk "custom";
                    },
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);
    }
}
