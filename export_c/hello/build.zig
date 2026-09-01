const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libRootModule = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .strip = true,
        .pic = true,
    });
    libRootModule.linkSystemLibrary("zlib", .{
        .use_pkg_config = .yes,
        .preferred_link_mode = .dynamic,
    });
    const libVersion: std.SemanticVersion = std.SemanticVersion.parse("0.1.0") catch blk: {
        _ = b.addFail("Failed to parse library version");
        break :blk .{ .major = 0, .minor = 0, .patch = 0 };
    };
    const lib = b.addLibrary(.{
        .name = "hello",
        .root_module = libRootModule,
        .linkage = .dynamic,
        .version = libVersion,
    });

    b.installArtifact(lib);

    const exeRootModule = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize, .strip = true });
    const exeVersion: std.SemanticVersion = std.SemanticVersion.parse("0.1.0") catch blk: {
        _ = b.addFail("Failed to parse executable version");
        break :blk .{ .major = 0, .minor = 0, .patch = 0 };
    };
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_module = exeRootModule,
        .version = exeVersion,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const libTestRootModule = b.createModule(.{ .root_source_file = b.path("src/root.zig"), .target = target, .optimize = optimize });
    const lib_unit_tests = b.addTest(.{ .name = "Library tests", .root_module = libTestRootModule });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exeTestRootModule = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });
    const exe_unit_tests = b.addTest(.{ .name = "Executable tests", .root_module = exeTestRootModule });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
