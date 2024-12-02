const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    var res: usize = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var times = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    var distances = std.mem.tokenizeScalar(u8, lines.next().?, ' ');

    _ = times.next();
    _ = distances.next();
    while (true) {
        const time_s = try std.fmt.parseInt(usize, times.next() orelse break, 10);
        const dist_s = try std.fmt.parseInt(usize, distances.next() orelse break, 10);
        var speed: usize = 1;
        var time_left: usize = time_s - speed;
        var num_wins: usize = 0;
        while (time_left > 0) : (time_left -= 1) {
            if (speed * time_left > dist_s) {
                num_wins += 1;
            }

            speed += 1;
        }

        if (res == 0) {
            res = num_wins;
        } else {
            res *= num_wins;
        }
    }

    std.debug.print("{}", .{res});
}
