const std = @import("std");
const build_capy = @import("capy"); // the build script for capy

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("rootmod", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "capy",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "rootmod", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const capy_dep = b.dependency("capy", .{
        .target = target,
        .optimize = optimize,
        .app_name = @as([]const u8, "Your Application"),
    });
    const capy = capy_dep.module("capy");
    exe.root_module.addImport("capy", capy);

    //onst run_step = b.step("run", "Run the app");
    const run_cmd = try build_capy.runStep(exe, .{ .args = b.args });
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(run_cmd);
    //const run_cmd = b.addRunArtifact(exe);
    //run_step.dependOn(&run_cmd.step);
    //run_cmd.step.dependOn(b.getInstallStep());

    //if (b.args) |args| {
    //    run_cmd.addArgs(args);
    //}
    //run_step.dependOn(&run_cmd);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);

}
