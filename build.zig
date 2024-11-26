const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const utils = b.addModule("utils", .{
        .root_source_file = b.path("src/utils.zig"),
    });

    var puzzles_dir = try b.build_root.handle.openDir("src/puzzles", .{ .iterate = true });
    var it = try puzzles_dir.walk(b.allocator);
    while (try it.next()) |entry| {
        const puzzle_id = std.fs.path.stem(entry.basename);
        const exe = b.addExecutable(.{
            .name = puzzle_id,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);
        exe.root_module.addAnonymousImport("puzzle", .{
            .root_source_file = b.path(b.pathJoin(&.{ "src", "puzzles", entry.path })),
            .imports = &.{
                .{ .name = "utils", .module = utils },
            },
        });
        exe.root_module.addImport("utils", utils);

        var puzzle_id_it = std.mem.tokenizeScalar(u8, puzzle_id, '-');
        const year = puzzle_id_it.next().?;
        const day = puzzle_id_it.next().?;
        const input_path = b.pathFromRoot(b.pathJoin(&.{ "input", year, day, "input.txt" }));

        const cfg = b.addOptions();
        cfg.addOption([]const u8, "input_path", input_path);
        exe.root_module.addOptions("cfg", cfg);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&exe.step);

        const run_step = b.step(puzzle_id, "");
        run_step.dependOn(&run_cmd.step);
    }
}
