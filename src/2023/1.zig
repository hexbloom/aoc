const std = @import("std");

pub fn solve(input: std.fs.File.Reader, ally: std.mem.Allocator) !void {
    var sum: u32 = 0;

    while (try input.readUntilDelimiterOrEofAlloc(ally, '\n', 256)) |line| {
        var first_digit: ?u8 = null;
        var last_digit: ?u8 = null;
        for (line) |char| {
            if (!std.ascii.isDigit(char)) {
                continue;
            }

            if (first_digit == null) {
                first_digit = char;
            } else {
                last_digit = char;
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
