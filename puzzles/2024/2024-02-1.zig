const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: isize = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var vals_it = std.mem.tokenizeAny(u8, line, " ");
        var val_list = std.ArrayList(isize).init(ally);
        while (vals_it.next()) |val| {
            try val_list.append(try std.fmt.parseInt(isize, val, 10));
        }
        const vals = val_list.items;

        var is_safe = true;
        const is_increasing = vals[1] > vals[0];
        for (1..vals.len) |i| {
            const diff = vals[i] - vals[i - 1];
            if (is_increasing) {
                if (diff < 1 or diff > 3) {
                    is_safe = false;
                    break;
                }
            } else {
                if (diff > -1 or diff < -3) {
                    is_safe = false;
                    break;
                }
            }
        }
        if (is_safe) {
            res += 1;
        }
    }

    std.debug.print("{}", .{res});
}
