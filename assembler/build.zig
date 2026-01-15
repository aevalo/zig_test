const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe1 = b.addExecutable(.{
        .name = "zig-prac1",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main1.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe1.root_module.addAssemblyFile(b.path("src/hello.s"));

    b.installArtifact(exe1);

    const run_cmd1 = b.addRunArtifact(exe1);

    run_cmd1.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd1.addArgs(args);
    }

    const run_step1 = b.step("run1", "Run the app");
    run_step1.dependOn(&run_cmd1.step);

    const exe1_tests = b.addTest(.{ .root_module = exe1.root_module });

    const test1_step = b.step("test1", "Run unit tests");
    test1_step.dependOn(&exe1_tests.step);

    const exe2 = b.addExecutable(.{
        .name = "zig-prac2",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main2.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe2.root_module.addAssemblyFile(b.path("src/hello.s"));

    b.installArtifact(exe2);

    const run_cmd2 = b.addRunArtifact(exe2);

    run_cmd2.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd2.addArgs(args);
    }

    const run_step2 = b.step("run2", "Run the app");
    run_step2.dependOn(&run_cmd2.step);

    const exe2_tests = b.addTest(.{ .root_module = exe2.root_module });

    const test2_step = b.step("test2", "Run unit tests");
    test2_step.dependOn(&exe2_tests.step);
}
