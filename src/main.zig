const std = @import("std");

const usage_text =
    \\Usage: mimire [options] <command> ...
    \\
    \\Organize and manage hosts during engagements
    \\
    \\Options:
    \\ -i, --ip-address <IP>     IP Address of the host you want to add
    \\ -h, --help               Help menu
;

//Remember, put your structs here

pub fn main() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const args = try std.process.argsAlloc(arena);

    const stdout_init = std.io.getStdOut();
    var stdout_bw = std.io.bufferedWriter(stdout_init.writer());
    const stdout = stdout_bw.writer();
    _ = stdout;

    var arg_i: usize = 1;

    while (arg_i < args.len) : (arg_i += 1) {
        const arg = args[arg_i];
        if (!std.mem.startsWith(u8, arg, "-")) {
            std.debug.print("TODO: still need to work on this part...\n\n", .{});
        } else if (std.mem.startsWith(u8, arg, "-i") or std.mem.startsWith(u8, arg, "--ip-address")) {
            std.debug.print("TODO: adding in IP address\n\n", .{});
        } else if (std.mem.startsWith(u8, arg, "-h") or std.mem.startsWith(u8, arg, "--help")) {
            std.debug.print(usage_text, .{});
            return std.process.cleanExit();
        } else {
            std.debug.print("Unrecognized argument: '{s}'\n{s}", .{ arg, usage_text });
            std.process.exit(1);
        }
    }

    std.debug.print("Welcome to mimire", .{});
}

//Put all functions below
