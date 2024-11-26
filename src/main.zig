const std = @import("std");
const cfg = @import("cfg");
const puzzle = @import("puzzle");
const utils = @import("utils");
const Context = utils.Context;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const ally = arena.allocator();

    const ctx = try Context.init(cfg.input_path, ally);
    try puzzle.solve(ctx);
}
