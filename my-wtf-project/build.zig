const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall, // key line
    });

    const exe = b.addExecutable(.{
        .name = "my-wtf-project",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = optimize != .Debug, // remove debug symbols
        }),
    });

    const duck = b.dependency("duck", .{
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("duck", duck.module("duck"));
    exe.linkLibrary(duck.artifact("duck"));

    b.installArtifact(exe);
}
