const std = @import("std");

extern fn hello_world(usize) void;

const msg = "Hello World!\n";

pub fn main() void {
    hello_world(@intFromPtr(msg));
}
