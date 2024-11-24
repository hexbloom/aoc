const std = @import("std");
const Context = @import("../Context.zig");
const String = @import("../String.zig");

pub fn solve(ctx: Context) !void {
    var sum: i32 = 0;

    for (try ctx.lines()) |line| {
        var str = String.init(ctx.ally);
        for (line) |char| {
            if (std.ascii.isDigit(char)) {
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
