const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zgl = b.dependency("zgl", .{
        .target = target,
        .optimize = optimize,
        .binding_version = "VERSION_3_3",
    });

    // const zgl_path = zgl.path("src/zgl.zig");

    // const patch_run = b.addSystemCommand(&.{"patch"});
    // patch_run.addFileArg(zgl_path);
    // patch_run.addFileArg(b.path("zgl_opengl_3_3.patch"));

    const exe = b.addExecutable(.{
        .name = "eraze",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.linkSystemLibrary("glfw", .{});
    exe.root_module.link_libc = true;
    exe.root_module.addImport("zgl", zgl.module("zgl"));
    exe.use_llvm = true;

    // exe.step.dependOn(&patch_run.step);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
