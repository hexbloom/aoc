const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    const patterns_line = lines.next().?;

    var patterns_list = std.ArrayList([]const u8).init(ally);
    var patterns_split = std.mem.tokenizeAny(u8, patterns_line, ", ");
    while (patterns_split.next()) |p| {
        try patterns_list.append(p);
    }
    const patterns = try patterns_list.toOwnedSlice();
    var memo = std.StringHashMap(usize).init(ally);

    var res: usize = 0;
    while (lines.next()) |line| {
        res += try getPossible(line, patterns, &memo);
    }
    std.debug.print("{}", .{res});
}

fn getPossible(design: []const u8, patterns: [][]const u8, memo: *std.StringHashMap(usize)) !usize {
    if (design.len == 0) {
        return 1;
    }

    if (memo.get(design)) |count| {
        return count;
    }

    var count: usize = 0;
    for (patterns) |pattern| {
        if (std.mem.startsWith(u8, design, pattern)) {
            count += try getPossible(design[pattern.len..], patterns, memo);
        }
    }

    try memo.put(design, count);
    return count;
}
