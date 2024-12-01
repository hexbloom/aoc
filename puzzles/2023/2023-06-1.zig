const puzzle = @import("puzzle");
const std = @import("std");
const utils = @import("utils");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

pub fn main() !void {
    const lines = try utils.readLines(ally, puzzle.input_path);

    var res: usize = 0;

    const times = try utils.split(ally, lines[0], " ");
    const distances = try utils.split(ally, lines[1], " ");

    for (times[1..], distances[1..]) |time, distance| {
        const time_s = try std.fmt.parseInt(usize, time, 10);
        const dist_s = try std.fmt.parseInt(usize, distance, 10);
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
