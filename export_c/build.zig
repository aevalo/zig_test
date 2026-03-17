const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall, // key line
    });

    const lib = b.addLibrary(.{
        .name = "mathtest",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/mathtest.zig"),
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
        .name = "test",
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
        .file = b.path("src/test.c"),
        .flags = flags,
    });

    //const h_path = lib.getEmittedH();
    //exe.step.dependOn(&h_path);

    exe.linkLibrary(lib);
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);

    const test_step = b.step("test", "Test the program");
    test_step.dependOn(&run_cmd.step);
}
