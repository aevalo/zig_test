const capy = @import("capy");
pub usingnamespace capy.cross_platform;

pub fn main() !void {
    try capy.init();

    var window = try capy.Window.init();
    window.setPreferredSize(800, 600);
    window.show();
    capy.runEventLoop();
}
