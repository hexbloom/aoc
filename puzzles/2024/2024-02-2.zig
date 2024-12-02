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

        if (isListSafe(vals)) {
            res += 1;
        } else {
            for (0..vals.len) |i| {
                var val_list_cpy = try val_list.clone();
                _ = val_list_cpy.orderedRemove(i);
                if (isListSafe(val_list_cpy.items)) {
                    res += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("{}", .{res});
}

fn isListSafe(vals: []const isize) bool {
    const is_increasing = vals[1] > vals[0];
    for (1..vals.len) |i| {
        const diff = vals[i] - vals[i - 1];
        if (is_increasing) {
            if (diff < 1 or diff > 3) {
                return false;
            }
        } else {
            if (diff > -1 or diff < -3) {
                return false;
            }
        }
    }
    return true;
}
