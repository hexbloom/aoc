const std = @import("std");
const Context = @import("../Context.zig");
const String = @import("../String.zig");

pub fn solve(ctx: Context) !void {
    var sum: i32 = 0;

    for (try ctx.lines()) |line| {
        var str = String.init(ctx.ally);
        for (0..line.len) |i| {
            if (getDigit(line, i)) |char| {
                if (str.len() < 2) {
                    try str.add(char);
                } else {
                    try str.set(char, 1);
                }
            }
        }

        if (str.len() == 1) {
            try str.add(try str.at(0));
        }

        sum += try str.parseInt();
    }

    std.debug.print("{}", .{sum});
}

fn getDigit(line: []const u8, char_index: usize) ?u8 {
    if (std.ascii.isDigit(line[char_index])) {
        return line[char_index];
    } else {
        const number_strings = [_][]const u8{
            "one",
            "two",
            "three",
            "four",
            "five",
            "six",
            "seven",
            "eight",
            "nine",
        };
        inline for (number_strings, 0..) |number_string, number_index| {
            if (std.mem.startsWith(u8, line[char_index..], number_string)) {
                return '1' + number_index;
            }
        }
    }
    return null;
}
