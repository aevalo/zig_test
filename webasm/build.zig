const std = @import("std");

const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
    .{ .cpu_arch = .wasm64, .os_tag = .freestanding },
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall, // key line
    });

    for (targets) |t| {
        const resolved_target = b.resolveTargetQuery(t);

        var add_exe = b.addExecutable(.{
            .name = "add_two",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/add_two.zig"),
                .target = resolved_target,
                .optimize = optimize,
                .strip = optimize != .Debug, // remove debug symbols
            }),
        });
        add_exe.entry = .disabled;
        add_exe.rdynamic = true;
        const add_target_output = b.addInstallArtifact(add_exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = t.zigTriple(b.allocator) catch blk: {
                        const fail_step = b.addFail("Failed to parse executable version");
                        b.getInstallStep().dependOn(&fail_step.step);
                        break :blk "custom";
                    },
                },
            },
        });
        b.getInstallStep().dependOn(&add_target_output.step);

        var math_exe = b.addExecutable(.{
            .name = "math",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/math.zig"),
                .target = resolved_target,
                .optimize = optimize,
                .strip = optimize != .Debug, // remove debug symbols
            }),
        });
        math_exe.entry = .disabled;
        math_exe.rdynamic = true;
        const math_target_output = b.addInstallArtifact(math_exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = t.zigTriple(b.allocator) catch blk: {
                        const fail_step = b.addFail("Failed to parse executable version");
                        b.getInstallStep().dependOn(&fail_step.step);
                        break :blk "custom";
                    },
                },
            },
        });
        b.getInstallStep().dependOn(&math_target_output.step);

        const cwd: ?[]u8 = std.fs.cwd().realpathAlloc(std.heap.page_allocator, ".") catch blk: {
            const fail_step = b.addFail("Out of memory");
            b.getInstallStep().dependOn(&fail_step.step);
            break :blk null;
        };
        if (cwd) |wd| {
            defer std.heap.page_allocator.free(wd);
            if (math_target_output.dest_dir) |dest_dir| {
                const tt = b.getInstallPath(.{ .custom = dest_dir.custom }, ".");

                const run_step = if (resolved_target.query.cpu_arch.? == .wasm32) b.step("run32", "Run the app") else b.step("run64", "Run the app");
                const node_bin: ?[]const u8 = b.findProgram(&[_][]const u8{
                    "node",
                }, &[_][]const u8{}) catch blk: {
                    const fail_step = b.addFail("Failed to locate node binary");
                    run_step.dependOn(&fail_step.step);
                    break :blk null;
                };
                if (node_bin) |node| {
                    //std.debug.print("node path: {s}\n", .{node_bin.?});
                    //std.debug.print("node path: {s}\n", .{node_bin orelse "<missing>"});
                    std.debug.print("node path: {s}\n", .{node});
                    //const argv: [2][]const u8 = .{ "node", "test.js" };
                    const argv: [3][]const u8 = .{ node, "test.js", tt };
                    const node_cmd = b.addSystemCommand(&argv);
                    run_step.dependOn(&node_cmd.step);
                    node_cmd.step.dependOn(b.getInstallStep());
                }
            }
        }
    }
}
