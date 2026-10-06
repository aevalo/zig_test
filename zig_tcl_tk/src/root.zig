const std = @import("std");
const Io = std.Io;

const tcl = @import("tcl");
const tk = @import("tk");

/// This is a documentation comment to explain the `printAnotherMessage` function below.
///
/// Accepting an `Io.Writer` instance is a handy way to write reusable code.
pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    const interp = tcl.Tcl_CreateInterp();
    const ret = tcl.Tcl_Init(interp);
    if (ret == tcl.TCL_ERROR) {
        std.debug.print("Got error code {}", .{ret});
    }
    tcl.Tcl_DeleteInterp(interp);
    tcl.Tcl_Finalize();
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
