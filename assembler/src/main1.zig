const std = @import("std");

extern fn hello_world(?[*:0]const u8) void;

const msg: [:0]const u8 = "Hello World!\n";

pub fn main() void {
    hello_world(msg.ptr);
}
