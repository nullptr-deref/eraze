const std = @import("std");
const gl = @import("zgl");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

const Renderer = @import("Renderer.zig");

const App = @This();

running: bool,
renderer: Renderer,
logger: Logger,

pub fn init(width: usize,
    height: usize,
    title: []const u8,
    io: std.Io,
    allocator: std.mem.Allocator,
) !App {
    return App{
        .running = true,
        .renderer = try Renderer.init(width, height, title, allocator),
        .logger = .{ .io = io },
    };
}

pub fn deinit(self: *App) void {
    self.renderer.deinit();
    self.running = false;
}

pub fn run(self: *App) anyerror!void {
    try self.logger.printMessage("trying to run the application", .{});
    glfw.glfwWindowHint(glfw.GLFW_DECORATED, glfw.GLFW_TRUE);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);

    self.running = true;
    var brick_buffers: [6]gl.Buffer = undefined;
    gl.genBuffers(&brick_buffers);

    try self.logger.printMessage("launched window", .{});
    while (!self.renderer.windowShouldClose()) {
        glfw.glfwPollEvents();
        self.renderer.renderFrame();
    }
}

//zig vim:et:ts=4:sw=4:tw=80
