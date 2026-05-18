# ziez-tls

TLS/HTTPS with HTTP→HTTPS redirect for [ziez](https://github.com/ziez-dev/ziez).

## Requirements

- Zig 0.16.0+

## Installation

In `build.zig.zon`:

```zig
.dependencies = .{
    .ziez = .{
        .url = "https://github.com/ziez-dev/ziez/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "ziez-0.0.1-zH20Gh1jAwADi2a_88hnfVHclInMW1YPLF_y7SS7CJ5Y",
    },
    .@"ziez-tls" = .{
        .url = "https://github.com/ziez-dev/tls/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "1220b1fe03d61a1cc83ee28e918e1a2e4f0e0d6d1e23844e0c0e28194a8bbbe9d2e8",
    },
},
```

In `build.zig`:

```zig
const tls_dep = b.dependency("ziez-tls", .{
    .target = target,
    .optimize = optimize,
});
exe_mod.addImport("ziez_tls", tls_dep.module("ziez-tls"));
```

## Quick Start

```zig
const std = @import("std");
const ziez = @import("ziez");
const ztls = @import("ziez_tls");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();


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

    try app.listen( "0.0.0.0:443");
}
```

## Configuration

**TlsConfig:**

| Option | Type | Default | Description |
|---|---|---|---|
| `cert` | `CertSource` | *(required)* | Certificate source (`.file_path` or `.bytes`) |
| `key` | `KeySource` | *(required)* | Private key source (`.file_path` or `.bytes`) |
| `min_version` | `TlsVersion` | `.tls_1_2` | Minimum TLS version (`.tls_1_2`, `.tls_1_3`) |
| `cipher_suites` | `[]const CipherSuite` | AES_128_GCM, CHACHA20_POLY1305, AES_256_GCM | Allowed cipher suites |
| `client_auth` | `ClientAuth` | `.none` | Client certificate requirement (`.none`, `.request`, `.require`) |
| `client_ca` | `?CertSource` | `null` | CA certificate for client verification |
| `sni_hostnames` | `?[]const []const u8` | `null` | SNI hostnames |

**RedirectHttpConfig:**

| Option | Type | Default | Description |
|---|---|---|---|
| `enabled` | `bool` | `true` | Enable HTTP→HTTPS redirect |
| `port` | `u16` | `80` | Port to listen for HTTP redirects |
| `to` | `?u16` | `null` | Target HTTPS port (defaults to app listen port) |
| `exclude` | `[]const []const u8` | `&.{}` | Paths to exclude from redirect |

## License

MIT
