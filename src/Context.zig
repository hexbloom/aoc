const std = @import("std");
const cfg = @import("cfg");

const Context = @This();

ally: std.mem.Allocator,
reader: std.fs.File.Reader,

pub fn init(puzzle: []const u8, ally: std.mem.Allocator) !Context {
    var it = std.mem.tokenizeScalar(u8, puzzle, '-');
    const year = it.next() orelse return error.InvalidInput;
    const puzzle_id = it.next() orelse return error.InvalidInput;
    const puzzle_filename = try std.mem.concat(ally, u8, &.{ puzzle_id, ".txt" });
    const puzzle_path = try std.fs.path.join(ally, &.{ cfg.input_root, year, puzzle_filename });
    const puzzle_input = try std.fs.cwd().openFile(puzzle_path, .{});
    return Context{
        .reader = puzzle_input.reader(),
        .ally = ally,
    };
}

pub fn lines(ctx: Context) ![][]const u8 {
    var array = std.ArrayList([]const u8).init(ctx.ally);
    while (try ctx.reader.readUntilDelimiterOrEofAlloc(ctx.ally, '\n', 256)) |line| {
        try array.append(line);
    }
    return try array.toOwnedSlice();
}

pub fn format(ctx: Context, comptime fmt: []const u8, args: anytype) ![]const u8 {
    var array = std.ArrayList(u8).init(ctx.ally);
    try std.fmt.format(array.writer(), fmt, args);
    return try array.toOwnedSlice();
}
