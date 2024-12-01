const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: i64 = 0;

    var left = std.ArrayList(i64).init(ally);
    var right = std.ArrayList(i64).init(ally);
    for (lines) |line| {
        const split = try utils.split(ally, line, " ");
        try left.append(try std.fmt.parseInt(i64, split[0], 10));
        try right.append(try std.fmt.parseInt(i64, split[1], 10));
    }

    std.sort.pdq(i64, left.items, {}, std.sort.asc(i64));
    std.sort.pdq(i64, right.items, {}, std.sort.asc(i64));

    for (left.items) |l| {
        var count: i64 = 0;
        while (std.mem.indexOfScalar(i64, right.items, l)) |index| {
            _ = right.swapRemove(index);
            count += 1;
        }
        res += count * l;
    }

    std.debug.print("{}", .{res});
}
