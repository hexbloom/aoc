const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: i64 = 0;

    var left = std.ArrayList(i64).init(ally);
    var right = std.ArrayList(i64).init(ally);
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ' ');
        try left.append(try std.fmt.parseInt(i64, split.next().?, 10));
        try right.append(try std.fmt.parseInt(i64, split.next().?, 10));
    }

    std.sort.pdq(i64, left.items, {}, std.sort.asc(i64));
    std.sort.pdq(i64, right.items, {}, std.sort.asc(i64));

    for (left.items, right.items) |l, r| {
        res += @intCast(@abs(r - l));
    }

    std.debug.print("{}", .{res});
}
