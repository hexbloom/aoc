const std = @import("std");
const String = @This();

ally: std.mem.Allocator,
buf: std.ArrayList(u8),

pub fn init(ally: std.mem.Allocator) String {
    return String{
        .ally = ally,
        .buf = std.ArrayList(u8).init(ally),
    };
}

pub fn add(str: *String, char: u8) !void {
    try str.buf.append(char);
}

pub fn at(str: String, index: usize) !u8 {
    if (index >= str.buf.items.len) {
        return error.InvalidIndex;
    }
    return str.buf.items[index];
}

pub fn set(str: *String, char: u8, index: usize) !void {
    if (index >= str.buf.items.len) {
        return error.InvalidIndex;
    }
    str.buf.items[index] = char;
}

pub fn len(str: String) usize {
    return str.buf.items.len;
}

pub fn parseInt(str: String) !i32 {
    return std.fmt.parseInt(i32, str.buf.items, 10);
}
