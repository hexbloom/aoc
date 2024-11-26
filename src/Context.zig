const std = @import("std");
const cfg = @import("cfg");

const Context = @This();

ally: std.mem.Allocator,
lines: [][]const u8,
linesAsInts: [][]const i32,
linesAsSingleInts: []const i32,
contents: []const u8,
contentsAsInts: []const i32,

pub fn init(puzzle: []const u8, ally: std.mem.Allocator) !Context {
    var it = std.mem.tokenizeScalar(u8, puzzle, '-');
    const year = it.next() orelse return error.InvalidInput;
    const puzzle_id = it.next() orelse return error.InvalidInput;
    const puzzle_filename = try std.mem.concat(ally, u8, &.{ puzzle_id, ".txt" });
    const puzzle_path = try std.fs.path.join(ally, &.{ cfg.input_root, year, puzzle_filename });
    const puzzle_input = try std.fs.cwd().openFile(puzzle_path, .{});
    const puzzle_reader = puzzle_input.reader();

    var lines = std.ArrayList([]const u8).init(ally);
    while (true) {
        var line = std.ArrayList(u8).init(ally);
        puzzle_reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };
        try lines.append(try line.toOwnedSlice());
    }

    var linesAsInts = std.ArrayList([]const i32).init(ally);
    for (lines.items) |line| {
        var lineAsInts = std.ArrayList(i32).init(ally);
        for (line) |char| {
            try lineAsInts.append(@as(i32, @intCast(char)) - '0');
        }
        try linesAsInts.append(try lineAsInts.toOwnedSlice());
    }

    var linesAsSingleInts = std.ArrayList(i32).init(ally);
    for (lines.items) |line| {
        const lineAsSingleInt = std.fmt.parseInt(i32, line, 10) catch continue;
        try linesAsSingleInts.append(lineAsSingleInt);
    }

    var contents = std.ArrayList(u8).init(ally);
    for (lines.items) |line| {
        try contents.appendSlice(line);
    }

    var contentsAsInts = std.ArrayList(i32).init(ally);
    for (linesAsInts.items) |lineAsInts| {
        try contentsAsInts.appendSlice(lineAsInts);
    }

    return Context{
        .ally = ally,
        .lines = try lines.toOwnedSlice(),
        .linesAsInts = try linesAsInts.toOwnedSlice(),
        .linesAsSingleInts = try linesAsSingleInts.toOwnedSlice(),
        .contents = try contents.toOwnedSlice(),
        .contentsAsInts = try contentsAsInts.toOwnedSlice(),
    };
}
