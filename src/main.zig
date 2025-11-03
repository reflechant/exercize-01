// const std = @import("std");
// const exercize_01 = @import("exercize_01");
const glfw = @import("zglfw");
const gl = @import("gl");

// Procedure table that will hold OpenGL functions loaded at runtime.
var procs: gl.ProcTable = undefined;

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    const window = try glfw.createWindow(600, 600, "OpenGL Window", null);
    defer glfw.destroyWindow(window);

    glfw.makeContextCurrent(window);

    // Initialize the procedure table.
    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    // Make the procedure table current on the calling thread.
    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    // setup your graphics context here
    while (!window.shouldClose()) {
        glfw.pollEvents();

        // render your things here
        // Use OpenGL functions
        gl.ClearColor(0.0, 0.0, 0.0, 1.0);
        gl.Clear(gl.COLOR_BUFFER_BIT);

        window.swapBuffers();
    }
}

// fn getProcAddress(_: ?*anyopaque, proc: [:0]const u8) ?*const anyopaque {
//     return glfw.getProcAddress(proc);
// }
