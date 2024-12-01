const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: i32 = 0;
    var id: i32 = 1;
    for (lines) |line| {
        var valid = true;

        var color_count_it = std.mem.tokenizeAny(u8, line, ":,;");
        _ = color_count_it.next();

        while (color_count_it.next()) |color_count| {
            var elem_it = std.mem.tokenizeScalar(u8, color_count, ' ');
            const count = elem_it.next() orelse return error.InvalidInput;
            const color = elem_it.next() orelse return error.InvalidInput;

            const max_count: u32 = blk: {
                if (std.mem.eql(u8, color, "red")) {
                    break :blk 12;
                } else if (std.mem.eql(u8, color, "green")) {
                    break :blk 13;
                } else if (std.mem.eql(u8, color, "blue")) {
                    break :blk 14;
                } else {
                    return error.InvalidInput;
                }
            };

            if (try std.fmt.parseInt(u32, count, 10) > max_count) {
                valid = false;
                break;
            }
        }

        if (valid) {
            res += id;
        }

        id += 1;
    }

    std.debug.print("{}", .{res});
}
