const std = @import("std");

pub const add = @import("add.zig").add;
pub const greet = @import("hello.zig").greet;
pub const hello_world = @import("hello.zig").hello_world;
pub const my_strlen = @import("my_strlen.zig").my_strlen;

test {
    std.testing.refAllDecls(@This());
}
