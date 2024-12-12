const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var stones = std.ArrayList(usize).init(ally);
    var vals = std.mem.tokenizeScalar(u8, input, ' ');
    while (vals.next()) |val| {
        try stones.append(try std.fmt.parseInt(usize, val, 10));
    }

    for (0..25) |_| {
        var next_stones = std.ArrayList(usize).init(ally);
        for (stones.items) |stone| {
            const num_digits = blk: {
                var rem = stone;
                var digits: usize = 0;
                while (rem > 0) {
                    digits += 1;
                    rem /= 10;
                }
                break :blk digits;
            };

            if (stone == 0) {
                try next_stones.append(1);
            } else if (num_digits % 2 == 0) {
                const digit_split = std.math.pow(usize, 10, num_digits / 2);
                try next_stones.append(stone / digit_split);
                try next_stones.append(stone % digit_split);
            } else {
                try next_stones.append(stone * 2024);
            }
        }
        stones = next_stones;
    }

    std.debug.print("{}", .{stones.items.len});
}
