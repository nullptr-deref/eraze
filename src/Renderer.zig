const std = @import("std");
const gl = @import("zgl");

const glfw = @cImport(@cInclude("GLFW/glfw3.h"));

const Renderer = @This();
const Logger = @import("Logger.zig");

pub const Context = struct {
    const Self = @This();

    native_handle: *glfw.GLFWwindow,

    fn init(width: usize, height: usize, title: []const u8) !Context {
        const ctx = glfw.glfwCreateWindow(
            @intCast(width),
            @intCast(height),
            @ptrCast(title),
            null,
            null,
        ) orelse return error.InvalidContext;

        return Context{ .native_handle = ctx };
    }

    fn deinit(self: Self) void {
        glfw.glfwDestroyWindow(self.native_handle);
    }
};

context: Context,
targets: std.ArrayList(RenderTarget),

pub fn init(
    width: usize,
    height: usize,
    title: []const u8,
    allocator: std.mem.Allocator,
) !Renderer {
    glfw.glfwWindowHint(glfw.GLFW_DECORATED, glfw.GLFW_FALSE);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);

    glfwInit() catch {
        const logger = Logger.init;
        var desc: [][:0]const u8 = undefined;
        _ = glfw.glfwGetError(@ptrCast(&desc));
        try logger.printError("{s}\n", .{desc});
        std.process.exit(127);
    };

    const context = try Context.init(width, height, title);
    swapInterval(1);
    glfw.glfwMakeContextCurrent(context.native_handle);
    try gl.binding.load(getProcAddress);

    gl.enable(gl.Capabilities.blend);
    gl.blendFunc(
        gl.BlendFactor.src_alpha,
        gl.BlendFactor.one_minus_src_alpha,
    );
    return Renderer{
        .context = context,
        .targets = std.ArrayList(RenderTarget).init(allocator),
    };
}

pub fn getProcAddress(pname: [:0]const u8) ?*const anyopaque {
    return glfw.glfwGetProcAddress(pname);
}

pub fn registerTarget(self: *Renderer, tgt: RenderTarget) error{OutOfMemory}!void {
    try self.targets.append(tgt);
}

fn swapInterval(interval: u32) void {
    glfw.glfwSwapInterval(@intCast(interval));
}

pub fn windowShouldClose(self: Renderer) bool {
    return glfw.glfwWindowShouldClose(self.context.native_handle) == glfw.GLFW_TRUE;
}

pub fn renderFrame(self: *Renderer) void {
    glfw.glfwSwapBuffers(self.context.native_handle);
    gl.clear(.{ .color = true });
    for (self.targets.items, 0..) |t, i| {
        std.debug.print("rendering target {}\n", .{i});
        t.vao.bind();
        t.vbo.buffer.bind(gl.BufferTarget.array_buffer);
        t.program.use();
        if (t.indices) |indices| {
            indices.buffer.bind(gl.BufferTarget.element_array_buffer);
            gl.drawElements(t.primitive_type, indices.len, indices.element_type.?, 0);
        } else {
            gl.drawArrays(t.primitive_type, 0, t.vbo.len);
        }
    }
}

pub fn setCurrentContext(self: *Renderer, ctx: *Context) void {
    self.context = ctx;
    glfw.glfwMakeContextCurrent(self.context.native_handle);
}

pub fn deinit(self: *Renderer) void {
    self.targets.deinit();
    self.context.deinit();
    glfw.glfwTerminate();
}

fn glfwInit() !void {
    if (glfw.glfwInit() == glfw.GLFW_FALSE) {
        return error.GlfwInitFailed;
    }
}

pub const SizedBuffer = struct {
    buffer: gl.Buffer,
    len: usize,
    element_type: ?gl.ElementType // present only if buffer is an element buffer
};

/// Render target is a wrapper around vertex buffer, vertex array and
/// shader program used to render them properly.
pub const RenderTarget = struct {
    program: gl.Program,
    vao: gl.VertexArray,
    vbo: SizedBuffer,
    indices: ?SizedBuffer,
    primitive_type: gl.PrimitiveType,
};

//zig vim:et:ts=4:sw=4:tw=80
