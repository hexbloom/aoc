const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const Block = struct {
    id: usize,
    len: usize,
};

pub fn main() !void {
    var file_list = std.ArrayList(Block).init(ally);
    var free_list = std.ArrayList(Block).init(ally);

    var next_id: usize = 0;
    var is_file = true;
    for (input) |c| {
        const val = try std.fmt.parseInt(usize, &.{c}, 10);

        const block = Block{ .id = next_id, .len = val };
        if (is_file) {
            try file_list.append(block);
            next_id += 1;
        } else {
            try free_list.append(block);
        }

        is_file = !is_file;
    }

    var checksum: usize = 0;
    var write_pos: usize = 0;
    var next_idx: usize = 0;
    var free_idx = file_list.items.len - 1;
    checksum_loop: while (true) {
        const file = file_list.items[next_idx];
        writeChecksum(file.id, file.len, &write_pos, &checksum);

        if (next_idx == free_idx) {
            break;
        }

        const free = free_list.items[next_idx];
        var free_rem = free.len;
        while (free_rem > 0) {
            const free_file = &file_list.items[free_idx];
            if (free_file.len <= free_rem) {
                writeChecksum(free_file.id, free_file.len, &write_pos, &checksum);
                free_rem -= free_file.len;
                free_idx -= 1;
            } else {
                writeChecksum(free_file.id, free_rem, &write_pos, &checksum);
                free_file.len -= free_rem;
                free_rem = 0;
            }

            if (next_idx == free_idx) {
                break :checksum_loop;
            }
        }

        next_idx += 1;
    }
    std.debug.print("{}", .{checksum});
}

fn writeChecksum(id: usize, count: usize, write_pos: *usize, checksum: *usize) void {
    for (0..count) |_| {
        checksum.* += write_pos.* * id;
        write_pos.* += 1;
    }
}
