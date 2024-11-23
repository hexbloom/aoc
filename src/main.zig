const std = @import("std");

pub const solutions = struct {
    pub const @"2023" = struct {
        pub const @"1" = @import("2023/1.zig");
    };
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const ally = arena.allocator();

    var args = try std.process.argsWithAllocator(ally);
    defer args.deinit();

    _ = args.skip();

    const year = args.next() orelse return error.InvalidArgs;
    const problem = args.next() orelse return error.InvalidArgs;
    const input = blk: {
        const path = args.next() orelse return error.InvalidArgs;
        const file = try std.fs.cwd().openFile(path, .{});
        break :blk file.reader();
    };

    std.debug.print("Chosen year: {s}\n", .{year});
    std.debug.print("Chosen problem: {s}\n", .{problem});

    inline for (@typeInfo(solutions).Struct.decls) |year_decl| {
        if (std.mem.eql(u8, year_decl.name, year)) {
            const year_solutions = @field(solutions, year_decl.name);
            inline for (@typeInfo(year_solutions).Struct.decls) |problem_decl| {
                if (std.mem.eql(u8, problem_decl.name, problem)) {
                    const problem_solution = @field(year_solutions, problem_decl.name);
                    try problem_solution.solve(input, ally);
                    return;
                }
            }
        }
    }
    return error.NoSolutionImplemented;
}
