const std = @import("std");

pub fn solve(input: std.fs.File.Reader, ally: std.mem.Allocator) !void {
    var sum: u32 = 0;

    while (try input.readUntilDelimiterOrEofAlloc(ally, '\n', 256)) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;
        for (0..line.len) |char_index| {
            if (getDigit(line, char_index)) |digit| {
                if (first_digit == null) {
                    first_digit = digit;
                } else {
                    last_digit = digit;
                }
            }
        }

        if (first_digit == null) {
            return error.InvalidInput;
        }

        if (last_digit == null) {
            last_digit = first_digit;
        }

        var number_buffer: [2]u8 = .{ first_digit.?, last_digit.? };
        sum += try std.fmt.parseInt(u32, number_buffer[0..], 10);
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
