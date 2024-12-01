const std = @import("std");

pub const grid = @import("grid.zig");

pub fn readLines(ally: std.mem.Allocator, input_path: []const u8) ![][]const u8 {
    const input_file = try std.fs.cwd().openFile(input_path, .{});
    const input_reader = input_file.reader();

    var lines = std.ArrayList([]const u8).init(ally);
    while (true) {
        var line = std.ArrayList(u8).init(ally);
        input_reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };
        try lines.append(try line.toOwnedSlice());
    }
    return lines.toOwnedSlice();
}

pub fn split(ally: std.mem.Allocator, buffer: []const u8, delim: []const u8) ![][]const u8 {
    var arr = std.ArrayList([]const u8).init(ally);
    var it = std.mem.tokenizeAny(u8, buffer, delim);
    while (it.next()) |str| {
        try arr.append(str);
    }
    return try arr.toOwnedSlice();
}
