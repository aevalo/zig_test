const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "mathtest",
        .target = target,
        .optimize = mode,
        .root_source_file = b.path("src/mathtest.zig"),
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });

    lib.installHeadersDirectory(b.path("include"), "", .{});
    b.installArtifact(lib);

    //const header_install = b.addInstallHeaderFile(
    //    b.path("include/mathtest.h"),
    //    "mathtest.h",
    //);
    //b.getInstallStep().dependOn(&header_install.step);

    const exe = b.addExecutable(.{
        .name = "test",
        .target = target,
        .optimize = mode,
        .link_libc = true,
    });

    exe.addCSourceFile(.{
        .file = b.path("src/test.c"),
        .flags = &[_][]const u8{"-std=c11"},
    });

    exe.linkLibrary(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    const test_step = b.step("test", "Test the program");
    test_step.dependOn(&run_cmd.step);
}
