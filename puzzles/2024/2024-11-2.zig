const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const NextVal = struct {
    first: usize,
    second: ?usize = null,
};

pub fn main() !void {
    var vals = std.mem.tokenizeScalar(u8, input, ' ');
    var val_map = std.AutoHashMap(usize, usize).init(ally);
    while (vals.next()) |val| {
        try val_map.put(try std.fmt.parseInt(usize, val, 10), 1);
    }

    for (0..75) |_| {
        var next_val_map = std.AutoHashMap(usize, usize).init(ally);
        var val_it = val_map.iterator();
        while (val_it.next()) |v| {
            const val = v.key_ptr.*;
            const next = getNextVal(val);
            try putNextVal(val, next.first, val_map, &next_val_map);
            if (next.second) |second| {
                try putNextVal(val, second, val_map, &next_val_map);
            }
        }
        val_map = next_val_map;
    }

    var res: usize = 0;
    var val_it = val_map.iterator();
    while (val_it.next()) |v| {
        res += v.value_ptr.*;
    }
    std.debug.print("{}", .{res});
}

fn putNextVal(
    val: usize,
    next_val: usize,
    vals: std.AutoHashMap(usize, usize),
    next_vals: *std.AutoHashMap(usize, usize),
) !void {
    const cur = vals.get(val) orelse unreachable;
    const next = try next_vals.getOrPutValue(next_val, 0);
    next.value_ptr.* += cur;
}

fn getNextVal(val: usize) NextVal {
    const num_digits = blk: {
        var rem = val;
        var digits: usize = 0;
        while (rem > 0) {
            digits += 1;
            rem /= 10;
        }
        break :blk digits;
    };

    if (val == 0) {
        return .{ .first = 1 };
    } else if (num_digits % 2 == 0) {
        const digit_split = std.math.pow(usize, 10, num_digits / 2);
        return .{
            .first = val / digit_split,
            .second = val % digit_split,
        };
    } else {
        return .{ .first = val * 2024 };
    }
}
