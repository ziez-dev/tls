const std = @import("std");
const ziez = @import("ziez");
const ztls = @import("ziez_tls");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var threaded = std.Io.Threaded.init_single_threaded;
    const io = threaded.io();

    var app = ziez.init(allocator);
    defer app.deinit();

    try ztls.setup(&app, .{
        .tls = .{
            .cert = .{ .file_path = "cert.pem" },
            .key = .{ .file_path = "key.pem" },
        },
        .redirect = .{ .port = 80 },
    });

    app.get("/", struct {
        fn h(_: *ziez.Request, res: *ziez.Response) !void {
            res.json(.{ .message = "Hello over HTTPS!" });
        }
    }.h);

    try app.listen(io, "0.0.0.0:443");
}
