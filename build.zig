const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var puzzles_dir = try b.build_root.handle.openDir("puzzles", .{ .iterate = true });
    var it = try puzzles_dir.walk(b.allocator);
    while (try it.next()) |entry| {
        if (entry.kind != .file) {
            continue;
        }
        const puzzle_id = std.fs.path.stem(entry.basename);
        const exe = b.addExecutable(.{
            .name = puzzle_id,
            .root_source_file = b.path(b.pathJoin(&.{ "puzzles", entry.path })),
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(exe);

        var puzzle_id_it = std.mem.tokenizeScalar(u8, puzzle_id, '-');
        const year = puzzle_id_it.next().?;
        const day = puzzle_id_it.next().?;
        exe.root_module.addAnonymousImport("puzzle_input", .{
            .root_source_file = b.path(b.pathJoin(&.{ "input", year, day, "input.txt" })),
        });

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(&exe.step);

        const run_step = b.step(puzzle_id, "");
        run_step.dependOn(&run_cmd.step);
    }
}
