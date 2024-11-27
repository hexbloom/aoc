const std = @import("std");

pub const Context = @import("Context.zig");
pub const grid = @import("grid.zig");

pub fn split(ally: std.mem.Allocator, buffer: []const u8, delim: []const u8) ![][]const u8 {
    var arr = std.ArrayList([]const u8).init(ally);
    var it = std.mem.tokenizeAny(u8, buffer, delim);
    while (it.next()) |str| {
        try arr.append(str);
    }
    return try arr.toOwnedSlice();
}
