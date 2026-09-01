const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("zig_dynlib", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "zig_dynlib",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zig_dynlib", .module = mod },
            },
            .link_libc = true,
        }),
    });

    b.installArtifact(exe);

    const dynlib_mod = b.addModule("mydynlib", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
    });

    const dynlib = b.addLibrary(.{
        .name = "mydynlib",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/libroot.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "mydynlib", .module = dynlib_mod },
            },
            .pic = true,
            .strip = optimize != .Debug,
        }),
    });

    b.installArtifact(dynlib);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const dynlib_mod_tests = b.addTest(.{
        .root_module = dynlib_mod,
    });

    const run_dynlib_mod_tests = b.addRunArtifact(dynlib_mod_tests);

    const dynlib_tests = b.addTest(.{
        .root_module = dynlib.root_module,
    });

    const run_dynlib_tests = b.addRunArtifact(dynlib_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_dynlib_mod_tests.step);
    test_step.dependOn(&run_dynlib_tests.step);
}
