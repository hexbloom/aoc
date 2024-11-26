const std = @import("std");
const utils = @import("utils");
const grid = utils.grid;
const Context = utils.Context;

pub fn solve(ctx: Context) !void {
    var res: i32 = 0;

    var map = std.AutoHashMap(grid.Cell, std.ArrayList(i32)).init(ctx.ally);
    for (ctx.lines, 0..) |line, y| {
        var it = std.mem.tokenizeAny(u8, line, "!@#$%^&*()-=_+/.");
        while (it.next()) |num| {
            var gear_cell: ?grid.Cell = null;
            const start = @intFromPtr(num.ptr) - @intFromPtr(line.ptr);
            for (0..num.len) |i| {
                const x = start + i;
                for (try grid.getAdjCells(ctx.ally, ctx.lines, x, y, &grid.adj_all)) |cell| {
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
