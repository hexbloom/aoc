const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var copies_list = std.ArrayList(i32).init(ally);
    while (lines.next()) |_| {
        try copies_list.append(0);
    }
    const copies = try copies_list.toOwnedSlice();

    lines.reset();
    var line_idx: usize = 0;
    while (lines.next()) |line| : (line_idx += 1) {
        var split = std.mem.tokenizeAny(u8, line, ":|");
        _ = split.next();

        var vals = std.mem.tokenizeScalar(u8, split.next().?, ' ');
        var checks = std.mem.tokenizeScalar(u8, split.next().?, ' ');

        var num_matches: i32 = 0;
        while (checks.next()) |c| {
            while (vals.next()) |v| {
                if (std.mem.eql(u8, c, v)) {
                    num_matches += 1;
                }
            }
            vals.reset();
        }

        copies[line_idx] += 1;
        for (0..@intCast(num_matches)) |match_idx| {
            const set_idx = line_idx + match_idx + 1;
            if (set_idx >= copies.len) {
                break;
            }
            copies[set_idx] += copies[line_idx];
        }
    }

    for (copies) |c| {
        res += c;
    }

    std.debug.print("{}", .{res});
}
