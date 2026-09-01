const std = @import("std");

fn add_mathtest(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, run_step: *std.Build.Step, test_step: *std.Build.Step) void {
    const lib = b.addLibrary(.{
        .name = "mathtest",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mathtest/mathtest.zig"),
            .target = target,
            .optimize = optimize,
            .pic = true,
            .strip = optimize != .Debug, // remove debug symbols
        }),
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });

    lib.installHeadersDirectory(b.path("include"), "", .{});
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "mathtest",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .strip = optimize != .Debug, // remove debug symbols
        }),
    });

    const release_flags = [_][]const u8{ "--std=c11", "-O3" };
    const debug_flags = [_][]const u8{"--std=c11"};
    const flags = if (optimize == .Debug) &debug_flags else &release_flags;
    exe.root_module.addCSourceFile(.{
        .file = b.path("src/mathtest/test.c"),
        .flags = flags,
    });

    //const h_path = lib.getEmittedH();
    //exe.step.dependOn(&h_path);

    exe.root_module.linkLibrary(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const lib_tests = b.addTest(.{
        .root_module = lib.root_module,
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);

    test_step.dependOn(&run_lib_tests.step);
}

fn add_zlibtest(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, run_step: *std.Build.Step, test_step: *std.Build.Step) void {
    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/zlibtest/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = optimize != .Debug,
        .pic = true,
    });
    lib_mod.linkSystemLibrary("zlib", .{
        .use_pkg_config = .yes,
        .preferred_link_mode = .dynamic,
    });
    const libVersion: std.SemanticVersion = std.SemanticVersion.parse("0.1.0") catch blk: {
        _ = b.addFail("Failed to parse library version");
        break :blk .{ .major = 0, .minor = 0, .patch = 0 };
    };
    const lib = b.addLibrary(.{
        .name = "zlib-zig",
        .root_module = lib_mod,
        .linkage = .dynamic,
        .version = libVersion,
    });

    b.installArtifact(lib);

    const bin_mod = b.createModule(.{
        .root_source_file = b.path("src/zlibtest/main.zig"),
        .target = target,
        .optimize = optimize,
        .strip = optimize != .Debug,
        .imports = &.{
            .{ .name = "zlib", .module = lib_mod },
        },
    });
    const exeVersion: std.SemanticVersion = std.SemanticVersion.parse("0.1.0") catch blk: {
        _ = b.addFail("Failed to parse executable version");
        break :blk .{ .major = 0, .minor = 0, .patch = 0 };
    };
    const exe = b.addExecutable(.{
        .name = "zlibtest",
        .root_module = bin_mod,
        .version = exeVersion,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    run_step.dependOn(&run_cmd.step);

    const libTestRootModule = b.createModule(.{ .root_source_file = b.path("src/zlibtest/root.zig"), .target = target, .optimize = optimize });
    const lib_unit_tests = b.addTest(.{ .name = "Library tests", .root_module = libTestRootModule });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exeTestRootModule = b.createModule(.{ .root_source_file = b.path("src/zlibtest/main.zig"), .target = target, .optimize = optimize });
    const exe_unit_tests = b.addTest(.{ .name = "Executable tests", .root_module = exeTestRootModule });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall, // key line
    });

    const run_step = b.step("run", "Run the app");
    const test_step = b.step("test", "Test the program");

    add_mathtest(b, target, optimize, run_step, test_step);
    add_zlibtest(b, target, optimize, run_step, test_step);
}
