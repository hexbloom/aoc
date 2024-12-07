const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeAny(u8, line, ": ");
        const val = try std.fmt.parseInt(usize, split.next().?, 10);
        var nums_list = std.ArrayList(usize).init(ally);
        while (split.next()) |num| {
            try nums_list.append(try std.fmt.parseInt(usize, num, 10));
        }
        const nums = try nums_list.toOwnedSlice();
        const ops = try ally.alloc(u8, nums.len - 1);

        if (try isSolvable(nums, ops, val, 0)) {
            res += val;
        }
    }

    std.debug.print("{}", .{res});
}

fn isSolvable(nums: []const usize, ops: []u8, val: usize, index: usize) !bool {
    if (index == ops.len) {
        var res = nums[0];
        for (nums[1..], ops) |num, op| {
            switch (op) {
                '+' => res += num,
                '*' => res *= num,
                '|' => {
                    var buf = std.ArrayList(u8).init(ally);
                    try std.fmt.format(buf.writer(), "{}{}", .{ res, num });
                    res = try std.fmt.parseInt(usize, buf.items, 10);
                },
                else => unreachable,
            }
        }
        return res == val;
    } else {
        ops[index] = '+';
        const res1 = try isSolvable(nums, ops, val, index + 1);
        ops[index] = '*';
        const res2 = try isSolvable(nums, ops, val, index + 1);
        ops[index] = '|';
        const res3 = try isSolvable(nums, ops, val, index + 1);
        return res1 or res2 or res3;
    }
}
