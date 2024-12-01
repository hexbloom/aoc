const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: i32 = 0;

    for (lines) |line| {
        const split = try utils.split(ally, line, ":|");
        const vals = try utils.split(ally, split[1], " ");
        const checks = try utils.split(ally, split[2], " ");

        var num_matches: i32 = 0;
        for (checks) |c| {
            for (vals) |v| {
                if (std.mem.eql(u8, c, v)) {
                    num_matches += 1;
                }
            }
        }

        if (num_matches > 0) {
            res += std.math.pow(i32, 2, num_matches - 1);
        }
    }

    std.debug.print("{}", .{res});
}
