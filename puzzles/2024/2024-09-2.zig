const std = @import("std");
const input = @embedFile("puzzle_input");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const ally = gpa.allocator();

const BlockType = union(enum) {
    file: struct {
        id: usize,
        can_move: bool,
    },
    free: void,
};

const Block = struct {
    type: BlockType,
    len: usize,
};

pub fn main() !void {
    var blocks = std.DoublyLinkedList(Block){};
    const BlockNode = std.DoublyLinkedList(Block).Node;

    var next_id: usize = 0;
    var is_file = true;
    for (input) |c| {
        const val = try std.fmt.parseInt(usize, &.{c}, 10);

        const node = try ally.create(BlockNode);
        node.* = .{
            .data = Block{
                .type = if (is_file) .{ .file = .{ .id = next_id, .can_move = true } } else .free,
                .len = val,
            },
        };
        blocks.append(node);

        if (is_file) {
            next_id += 1;
        }
        is_file = !is_file;
    }

    var move_node = blocks.last;
    while (move_node) |move| : (move_node = move.prev) {
        switch (move.data.type) {
            .file => |f| {
                if (!f.can_move) {
                    continue;
                }
            },
            .free => continue,
        }

        var free_node = blocks.first;
        while (free_node) |free| : (free_node = free.next) {
            if (free == move) {
                break;
            } else if (free.data.type != .free or free.data.len < move.data.len) {
                continue;
            }

            const moved_node = try ally.create(BlockNode);
            moved_node.* = move.*;
            moved_node.data.type.file.can_move = false;
            blocks.insertBefore(free, moved_node);
            free.data.len -= move.data.len;

            move.data.type = .free;

            break;
        }
    }

    var checksum: usize = 0;
    var write_pos: usize = 0;
    var write_node = blocks.first;
    while (write_node) |write| : (write_node = write.next) {
        switch (write.data.type) {
            .file => |f| {
                writeChecksum(f.id, write.data.len, &write_pos, &checksum);
            },
            .free => write_pos += write.data.len,
        }
    }
    std.debug.print("{}", .{checksum});
}

fn writeChecksum(id: usize, count: usize, write_pos: *usize, checksum: *usize) void {
    for (0..count) |_| {
        checksum.* += write_pos.* * id;
        write_pos.* += 1;
    }
}
