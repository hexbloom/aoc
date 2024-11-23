const std = @import("std");

pub const puzzles = struct {
    pub const @"2023-1" = @import("2023/1.zig");
    pub const @"2023-1-2" = @import("2023/1p2.zig");
    pub const @"2023-2" = @import("2023/2.zig");
    pub const @"2023-2-2" = @import("2023/2p2.zig");
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const ally = arena.allocator();

    var args = try std.process.argsWithAllocator(ally);
    defer args.deinit();

    _ = args.skip();

    const puzzle_name = args.next() orelse return error.InvalidArgs;
    const puzzle_input = blk: {
        const path = args.next() orelse return error.InvalidArgs;
        const file = try std.fs.cwd().openFile(path, .{});
        break :blk file.reader();
    };

    inline for (@typeInfo(puzzles).Struct.decls) |puzzle_decl| {
        if (std.mem.eql(u8, puzzle_decl.name, puzzle_name)) {
            const puzzle = @field(puzzles, puzzle_decl.name);
            try puzzle.solve(puzzle_input, ally);
            return;
        }
    }
    return error.NoSolutionImplemented;
}
