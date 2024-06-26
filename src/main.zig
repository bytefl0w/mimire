const std = @import("std");
const Managed = @import("json_wrapper.zig").Managed;

const Host = struct { os: []const u8, ip_address: []const u8, hostname: []const u8, domain: []const u8 };

const Usage_Text =
    \\Usage: mimire [options] <command> ...
    \\
    \\Organize and manage hosts during engagements
    \\
    \\Sub-commands:
    \\ add                      Add a host to mimire storage
    \\ remove                   Remove a host from mimire storage
    \\ info                     Get information about a host
    \\
    \\Options:
    \\ -h, --help               Help menu
    \\
;

const Add_Usage_Text =
    \\Usage: mimire add <options> ...
    \\
    \\Add a host to mimire storage
    \\
    \\Options:
    \\ -i, --ip-address <IP>        IP Address of the host
    \\ -u, --username <username>    Username of the initial account
    \\ -p, --passowrd <password>    Password of the initial account
    \\ -d, --domain <domain>        Domain the host resides in
    \\ -a, --access [true,false]    Do you have access to this machine?
    \\
;

//Remember, put your structs here

pub fn main() !void {
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    // Grab the input from the command line
    const args = try std.process.argsAlloc(arena);

    const stdout_init = std.io.getStdOut();
    var stdout_bw = std.io.bufferedWriter(stdout_init.writer());
    const stdout = stdout_bw.writer();
    _ = stdout;

    // Read and parse the mimire.json file
    const parse_file = try parseJson("/home/bytefl0w/.local/mimire.json", arena);
    _ = parse_file;
    //std.debug.print("TESTING\nIP_ADDRESS: {s}\n", .{parse_file.value.ip_address});

    //TODO: Now write to the mimire.json file (Just overwrite it completely since we
    //are reading in the whole thing)

    var arg_i: usize = 1;
    while (arg_i < args.len) : (arg_i += 1) {
        const arg = args[arg_i];

        // TODO: does it really matter if I use if-else statements here?
        // Or would using switch statements be better?

        if (std.mem.startsWith(u8, arg, "add")) {
            // This part will parse out what the subcommand is
            _ = try add_host(args);
            break;
        } else if (std.mem.startsWith(u8, arg, "-h") or std.mem.startsWith(u8, arg, "--help")) {
            std.debug.print(Usage_Text, .{});
            return std.process.cleanExit();
        } else {
            std.debug.print("Unrecognized argument: '{s}'\n{s}", .{ arg, Usage_Text });
            std.process.exit(1);
        }
    }
}

fn add_host(args: [][:0]u8) !Host {
    var new_host = Host{ .os = undefined, .domain = undefined, .ip_address = undefined, .hostname = undefined };

    var arg_i: usize = 2;
    while (arg_i < args.len) : (arg_i += 1) {
        const arg = args[arg_i];
        if (std.mem.startsWith(u8, arg, "-h") or std.mem.startsWith(u8, arg, "--help")) {
            std.debug.print(Add_Usage_Text, .{});
        } else if (std.mem.startsWith(u8, arg, "-i") or std.mem.startsWith(u8, arg, "--ip-address")) {
            new_host.ip_address = args[arg_i + 1];
            arg_i += 2;
        } else if (std.mem.startsWith(u8, arg, "-d") or std.mem.startsWith(u8, arg, "--domain")) {
            new_host.domain = args[arg_i + 1];
            arg_i += 2;
            //} else if (std.mem.startsWith(u8, arg, "-a") or std.mem.startsWith(u8, arg, "--access")) {
            //    new_host.access = true; //TODO: change this
            //    arg_i += 2;
        } else if (std.mem.startsWith(u8, arg, "-h") or std.mem.startsWith(u8, arg, "--hostname")) {
            new_host.hostname = args[arg_i + 1];
            arg_i += 2;
        } else if (std.mem.startsWith(u8, arg, "-o") or std.mem.startsWith(u8, arg, "--os")) {
            new_host.os = args[arg_i + 1];
            arg_i += 2;
        } else {
            std.debug.print("Unrecognized argument: '{s}'\n{s}", .{ arg, Add_Usage_Text });
            std.process.exit(1);
        }
    }
    return new_host;
}

fn parseJson(file_path: []const u8, allocator: std.mem.Allocator) !Managed(Host) {
    const file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = std.json.reader(allocator, buffered.reader());
    defer reader.deinit();

    const parsed = try std.json.parseFromTokenSource(Host, allocator, &reader, .{
        .allocate = .alloc_always,
    });
    return Managed(Host).fromJson(parsed);
}

fn parseCmd(list: *[]const u8, cmd: []const u8) !void {
    _ = list;
    var it = std.mem.tokenizeScalar(u8, cmd, ' ');
    while (it.next()) |s| {
        _ = s;
    }
}
