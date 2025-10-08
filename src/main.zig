const std = @import("std");
const gl = @import("zgl");

const App = @import("App.zig");

const opengl_error_handling = gl.ErrorHandling.assert;

pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;
    const io = init.io;

    const game_title = "eraze";
    try std.Io.File.stdout().writeStreamingAll(io, "launching app...\n");
    var app = try App.init(640, 480, game_title, io, gpa);
    defer app.deinit();

    try app.run();
}

//zig vim:et:ts=4:sw=4:tw=80
