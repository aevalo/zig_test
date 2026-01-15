const std = @import("std");
const DuckDb = @import("duck");

pub fn main() !void {
    // setup database
    var duck = try DuckDb.init(null);
    defer duck.deinit();
}
