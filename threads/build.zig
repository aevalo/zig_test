const std = @import("std");

pub fn build(b: *std.Build) void {
    // const windows = b.option(bool, "windows", "Target Microsoft Windows") orelse false;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe1 = b.addExecutable(.{
        .name = "threads1",
        .root_source_file = b.path("threads1.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe1);

    const exe2 = b.addExecutable(.{
        .name = "threads2",
        .root_source_file = b.path("threads2.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe2);

    const exe3 = b.addExecutable(.{
        .name = "threads3",
        .root_source_file = b.path("threads3.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe3);

    const exe4 = b.addExecutable(.{
        .name = "threads4",
        .root_source_file = b.path("threads4.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe4);

    const exe5 = b.addExecutable(.{
        .name = "threads5",
        .root_source_file = b.path("threads5.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe5);
}