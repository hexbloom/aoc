const std = @import("std");
const cfg = @import("cfg");

const Context = @This();

ally: std.mem.Allocator,
lines: std.ArrayList(std.ArrayList(u8)),

pub fn init(puzzle: []const u8, ally: std.mem.Allocator) !Context {
    var it = std.mem.tokenizeScalar(u8, puzzle, '-');
    const year = it.next() orelse return error.InvalidInput;
    const puzzle_id = it.next() orelse return error.InvalidInput;
    const puzzle_filename = try std.mem.concat(ally, u8, &.{ puzzle_id, ".txt" });
    const puzzle_path = try std.fs.path.join(ally, &.{ cfg.input_root, year, puzzle_filename });
    const puzzle_input = try std.fs.cwd().openFile(puzzle_path, .{});
    const puzzle_reader = puzzle_input.reader();

    var lines = std.ArrayList(std.ArrayList(u8)).init(ally);
    while (true) {
        var line = std.ArrayList(u8).init(ally);
        puzzle_reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };
        try lines.append(line);
    }

    return Context{
        .ally = ally,
        .lines = lines,
    };
}
