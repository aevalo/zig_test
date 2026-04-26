const std = @import("std");

const targets = [_]std.Target.Query{
    .{}, // native
    //.{ .cpu_arch = .aarch64, .os_tag = .macos },
    //.{ .cpu_arch = .aarch64, .os_tag = .linux },
    //.{ .cpu_arch = .x86_64, .os_tag = .linux },
    //.{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    //.{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    //.{ .cpu_arch = .x86_64, .os_tag = .windows },
};

pub fn build(b: *std.Build) !void {
    const run_step = b.step("run", "Run the application");
    const test_step = b.step("test", "Run unit tests");
    // const target_opts = b.standardTargetOptions(.{});
    // const optimize_opt = b.standardOptimizeOption(.{});

    for (targets) |t| {
        const exe = b.addExecutable(.{
            .name = "hello",
            .root_source_file = b.path("hello.zig"),
            .target = b.resolveTargetQuery(t),
            .optimize = .ReleaseSafe,
        });

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);

        const run_exe = b.addRunArtifact(exe);
        run_step.dependOn(&run_exe.step);

        const unit_tests = b.addTest(.{
            .root_source_file = b.path("hello.zig"),
            .target = b.resolveTargetQuery(t),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }

    // See: https://github.com/ziglang/zig/issues/20042
    for (targets) |t| {
        const exe = b.addExecutable(.{
            .name = "zip",
            .root_source_file = b.path("zip.zig"),
            .target = b.resolveTargetQuery(t),
            .optimize = .ReleaseSafe,
        });
        if (t.os_tag == .linux) {
            const triple = try std.Target.linuxTriple(b.resolveTargetQuery(t).result, b.allocator);
            std.debug.print("/usr/lib/{s}\n", .{triple});
        }
        exe.linkSystemLibrary("z");
        //exe.linkSystemLibrary2("z", .{ .preferred_link_mode = .dynamic });
        exe.linkLibC();

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);

        const run_exe = b.addRunArtifact(exe);
        run_step.dependOn(&run_exe.step);

        const unit_tests = b.addTest(.{
            .root_source_file = b.path("zip.zig"),
            .target = b.resolveTargetQuery(t),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }

    // See: https://github.com/ziglang/zig/issues/20042
    for (targets) |t| {
        const exe = b.addExecutable(.{
            .name = "zlib",
            .root_source_file = b.path("zlib.zig"),
            .target = b.resolveTargetQuery(t),
            .optimize = .ReleaseSafe,
        });
        if (t.os_tag == .linux) {
            const triple = try std.Target.linuxTriple(b.resolveTargetQuery(t).result, b.allocator);
            std.debug.print("/usr/lib/{s}\n", .{triple});
        }
        exe.linkSystemLibrary("zlib");
        //exe.linkSystemLibrary2("zlib", .{ .preferred_link_mode = .dynamic });
        exe.linkLibC();

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);

        const run_exe = b.addRunArtifact(exe);
        run_step.dependOn(&run_exe.step);

        const unit_tests = b.addTest(.{
            .root_source_file = b.path("zlib.zig"),
            .target = b.resolveTargetQuery(t),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }

    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(b.install_path).step);
    if (@import("builtin").os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("zig-cache")).step);
    }
}