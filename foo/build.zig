const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod_math = b.addModule("math", .{
        .root_source_file = b.path("src/math.zig"),
        .target = target,
    });

    const mod_foo = b.addModule("foo", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "math", .module = mod_math },
        },
    });

    const exe = b.addExecutable(.{
        .name = "foo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "foo", .module = mod_foo },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_math_tests = b.addTest(.{
        .root_module = mod_math,
    });
    const run_mod_math_tests = b.addRunArtifact(mod_math_tests);

    const mod_foo_tests = b.addTest(.{
        .root_module = mod_foo,
    });

    const run_mod_foo_tests = b.addRunArtifact(mod_foo_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_math_tests.step);
    test_step.dependOn(&run_mod_foo_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
