const std = @import("std");
const Context = @import("../Context.zig");
const Grid = @import("../Grid.zig");

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    var map = std.AutoHashMap(Grid.Cell, std.ArrayList(i32)).init(ctx.ally);
    for (ctx.lines, 0..) |line, y| {
        var it = std.mem.tokenizeAny(u8, line, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var gear_cell: ?Grid.Cell = null;
            const start = @intFromPtr(num.ptr) - @intFromPtr(line.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try Grid.getAdjacentCells(ctx, x, y, &Grid.adj_all)) |cell| {
                    const char = ctx.lines[cell.y][cell.x];
                    if (char == '*') {
                        gear_cell = cell;
                    }
                }
            }
            if (gear_cell) |cell| {
                const kvp = try map.getOrPutValue(cell, std.ArrayList(i32).init(ctx.ally));
                try kvp.value_ptr.append(try std.fmt.parseInt(i32, num, 10));
            }
        }
    }

    var it = map.valueIterator();
    while (it.next()) |val| {
        if (val.items.len == 2) {
            res += val.items[0] * val.items[1];
        }
    }

    std.debug.print("{}", .{res});
}
