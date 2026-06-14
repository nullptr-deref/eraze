const std = @import("std");
const gl = @import("zgl");

const App = @import("App.zig");

const opengl_error_handling = gl.ErrorHandling.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const game_title = "lumines";
    var app = try App.init(640, 480, game_title, allocator);
    const game_title = "eraze";
    defer app.deinit();

    try app.run();
}
