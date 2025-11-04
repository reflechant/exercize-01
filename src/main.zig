// const std = @import("std");
// const exercize_01 = @import("exercize_01");
const glfw = @import("zglfw");
const gl = @import("gl");

// Procedure table that will hold OpenGL functions loaded at runtime.
var procs: gl.ProcTable = undefined;

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    glfw.windowHint(glfw.WindowHint.context_version_major, 4);
    glfw.windowHint(glfw.WindowHint.context_version_minor, 1);
    glfw.windowHint(glfw.WindowHint.opengl_profile, glfw.OpenGLProfile.opengl_core_profile);
    glfw.windowHint(glfw.WindowHint.opengl_forward_compat, true);

    const window = try glfw.createWindow(600, 600, "OpenGL Window", null);
    defer window.destroy();

    glfw.makeContextCurrent(window);

    // Initialize the procedure table.
    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    // Make the procedure table current on the calling thread.
    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(0, 0, 600, 600);

    _ = glfw.setFramebufferSizeCallback(window, framebuffer_size_callback);

    // setup your graphics context here
    while (!window.shouldClose()) {
        process_input(window);

        // rendering
        gl.ClearColor(0.0, 0.0, 0.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        glfw.pollEvents();
        window.swapBuffers();
    }
}

fn framebuffer_size_callback(_: *glfw.Window, width: c_int, height: c_int) callconv(.c) void {
    gl.Viewport(0, 0, width, height);
}

fn process_input(window: *glfw.Window) void {
    if (window.getKey(glfw.Key.escape) == glfw.Action.press) {
        window.setShouldClose(true);
    }
}
