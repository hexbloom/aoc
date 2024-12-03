const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: usize = 0;

    var muls = std.mem.tokenizeSequence(u8, input, "mul(");
    while (muls.next()) |segment| {
        var args = std.mem.tokenizeScalar(u8, segment, ',');
        const left = args.next() orelse continue;
        const right = args.next() orelse continue;
        if (std.mem.indexOfScalar(u8, right, ')')) |end| {
            const left_num = std.fmt.parseInt(usize, left, 10) catch continue;
            const right_num = std.fmt.parseInt(usize, right[0..end], 10) catch continue;
            res += left_num * right_num;
        }
    }

    std.debug.print("{}", .{res});
}
