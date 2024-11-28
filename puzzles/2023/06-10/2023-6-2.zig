const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: usize = 0;

    const times = try utils.split(ctx.ally, ctx.lines[0], " ");
    const distances = try utils.split(ctx.ally, ctx.lines[1], " ");

    var time = std.ArrayList(u8).init(ctx.ally);
    for (times[1..]) |t| {
        try time.appendSlice(t);
    }

    var distance = std.ArrayList(u8).init(ctx.ally);
    for (distances[1..]) |d| {
        try distance.appendSlice(d);
    }

    const time_s = try std.fmt.parseInt(usize, time.items, 10);
    const dist_s = try std.fmt.parseInt(usize, distance.items, 10);
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

    std.debug.print("{}", .{res});
}
