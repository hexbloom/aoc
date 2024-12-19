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
    var memo = std.StringHashMap(bool).init(ally);

    var res: usize = 0;
    while (lines.next()) |line| {
        if (try isPossible(line, patterns, &memo)) {
            res += 1;
        }
    }
    std.debug.print("{}", .{res});
}

fn isPossible(design: []const u8, patterns: [][]const u8, memo: *std.StringHashMap(bool)) !bool {
    if (design.len == 0) {
        return true;
    }

    if (memo.get(design)) |possible| {
        return possible;
    }

    var possible = false;
    for (patterns) |pattern| {
        if (std.mem.startsWith(u8, design, pattern)) {
            if (try isPossible(design[pattern.len..], patterns, memo)) {
                possible = true;
                break;
            }
        }
    }

    try memo.put(design, possible);
    return possible;
}
