const std = @import("std");
const Context = @import("../Context.zig");
const String = std.ArrayList(u8);

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    for (ctx.lines.items) |line| {
        var str = String.init(ctx.ally);
        for (0..line.items.len) |i| {
            if (getDigit(line.items, i)) |char| {
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
