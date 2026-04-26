const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const opts = .{ .target = target, .optimize = optimize };
    const zbench_module = b.dependency("zbench", opts).module("zbench");

    const mod = b.addModule("testing", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });
    mod.addImport("zbench", zbench_module);

    const exe = b.addExecutable(.{
        .name = "testing",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "testing", .module = mod },
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

    //for (test_targets) |test_target| {
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    //run_mod_tests.skip_foreign_checks = true;
    const run_exe_tests = b.addRunArtifact(exe_tests);
    //run_exe_tests.skip_foreign_checks = true;

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    //}

    const bench = b.addExecutable(.{
        .name = "bench",
        .root_module = b.createModule(.{
            .root_source_file = b.path("benchmarks/bench.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "testing", .module = mod },
                .{ .name = "zbench", .module = zbench_module },
            },
        }),
    });
    b.installArtifact(bench);
    const bench_step = b.step("benchmark", "Benchmark the library");
    const run_bench_cmd = b.addRunArtifact(bench);
    bench_step.dependOn(&run_bench_cmd.step);
    run_bench_cmd.step.dependOn(b.getInstallStep());
}
