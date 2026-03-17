const std = @import("std");

const hellolib = @cImport({
    @cInclude("hello.h");
});

pub const hello_world = hellolib.hello_world;
pub const greet = hellolib.greet;
