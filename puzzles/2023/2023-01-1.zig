const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var str = std.ArrayList(u8).init(ally);
        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (str.items.len < 2) {
                    try str.append(char);
                } else {
                    str.items[1] = char;
                }
            }
        }

        if (str.items.len == 1) {
            try str.append(str.items[0]);
        }

        res += try std.fmt.parseInt(i32, str.items, 10);
    }

    std.debug.print("{}", .{res});
}
