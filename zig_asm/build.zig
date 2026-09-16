const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall, // key line
    });

    const asmlib = b.addLibrary(.{
        .name = "asmlib",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .strip = optimize != .Debug, // remove debug symbols
        }),
        .linkage = .static,
    });
    asmlib.root_module.addAssemblyFile(b.path("src/add.s"));
    asmlib.root_module.addAssemblyFile(b.path("src/hello.s"));
    asmlib.root_module.addAssemblyFile(b.path("src/my_strlen.s"));
    asmlib.installHeadersDirectory(b.path("src"), "asmlib", .{ .include_extensions = &.{".h"} });
    b.installArtifact(asmlib);

    const foolib = b.addLibrary(.{
        .name = "foolib",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/foo.zig"),
            .target = target,
            .optimize = optimize,
            .strip = optimize != .Debug, // remove debug symbols
        }),
        .linkage = .static,
    });
    foolib.root_module.addAssemblyFile(b.path("src/foo.s"));
    b.installArtifact(foolib);

    const mod = b.addModule("zig_asm", .{ .root_source_file = b.path("src/root.zig"), .target = target });
    mod.addIncludePath(b.path("src"));
    mod.linkLibrary(asmlib);
    mod.linkLibrary(foolib);

    const exe = b.addExecutable(.{
        .name = "zig_asm",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zig_asm", .module = mod },
                .{ .name = "foolib", .module = foolib.root_module },
            },
            .strip = optimize != .Debug, // remove debug symbols
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

    const mod_tests = b.addTest(.{ .root_module = mod, .test_runner = .{
        .path = b.path("src/test_runner.zig"),
        .mode = .simple,
    } });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{ .root_module = exe.root_module });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    const foo_tests = b.addTest(.{
        .root_module = foolib.root_module,
        .test_runner = .{
            .path = b.path("src/test_runner.zig"),
            .mode = .simple,
        },
    });
    const run_foo_tests = b.addRunArtifact(foo_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_foo_tests.step);
}
