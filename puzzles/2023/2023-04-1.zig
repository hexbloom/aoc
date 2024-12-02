const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
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

        if (num_matches > 0) {
            res += std.math.pow(i32, 2, num_matches - 1);
        }
    }

    std.debug.print("{}", .{res});
}
