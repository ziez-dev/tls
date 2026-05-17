const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ziez_dep = b.dependency("ziez", .{
        .target = target,
        .optimize = optimize,
    });
    const ziez_mod = ziez_dep.module("ziez");

    _ = b.addModule("ziez-tls", .{
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{
            .{ .name = "ziez", .module = ziez_mod },
        },
    });

    // ── Tests (auto-discover tests/*.test.zig) ──────────────────────────────
    const test_step = b.step("test", "Run tests");
    const io = b.graph.io;

    var test_dir = b.build_root.handle.openDir(io, "tests", .{ .iterate = true }) catch return;
    defer test_dir.close(io);

    var walker = test_dir.walk(b.allocator) catch return;
    defer walker.deinit();

    while (walker.next(io) catch null) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.basename, ".test.zig")) continue;

        const test_path = std.fmt.allocPrint(b.allocator, "tests/{s}", .{entry.path}) catch continue;

        const test_mod = b.createModule(.{
            .root_source_file = b.path(test_path),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "ziez", .module = ziez_mod },
                .{ .name = "ziez_tls", .module = b.addModule("ziez_tls_test", .{
                    .root_source_file = b.path("src/root.zig"),
                    .imports = &.{.{ .name = "ziez", .module = ziez_mod }},
                }) },
            },
        });

        const unit_test = b.addTest(.{
            .root_module = test_mod,
        });

        const run_unit_test = b.addRunArtifact(unit_test);
        test_step.dependOn(&run_unit_test.step);
    }
}
