const std = @import("std");
const tls = @import("ziez_tls");

test "RedirectHttpConfig.shouldRedirect - basic"
{
    const config = tls.RedirectHttpConfig{ .enabled = true, .exclude = &.{} };
    try std.testing.expect(config.shouldRedirect("/"));
    try std.testing.expect(config.shouldRedirect("/api"));
}

test "RedirectHttpConfig.shouldRedirect - excluded path"
{
    const config = tls.RedirectHttpConfig{
        .enabled = true,
        .exclude = &.{"/health"},
    };
    try std.testing.expect(!config.shouldRedirect("/health"));
    try std.testing.expect(config.shouldRedirect("/api"));
}

test "RedirectHttpConfig.shouldRedirect - disabled"
{
    const config = tls.RedirectHttpConfig{ .enabled = false };
    try std.testing.expect(!config.shouldRedirect("/"));
}

test "CipherSuite enum values"
{
    try std.testing.expect(tls.CipherSuite.AES_128_GCM_SHA256 == @as(u16, 0x1301));
    try std.testing.expect(tls.CipherSuite.AES_256_GCM_SHA384 == @as(u16, 0x1302));
    try std.testing.expect(tls.CipherSuite.CHACHA20_POLY1305_SHA256 == @as(u16, 0x1303));
}

test "TlsConfig defaults"
{
    const config = tls.TlsConfig{
        .cert = .{ .file_path = "cert.pem" },
        .key = .{ .file_path = "key.pem" },
    };
    try std.testing.expect(config.min_version == .tls_1_2);
    try std.testing.expect(config.client_auth == .none);
    try std.testing.expect(config.client_ca == null);
    try std.testing.expect(config.sni_hostnames == null);
    try std.testing.expect(config.cipher_suites.len == 3);
}

test "RedirectHttpConfig defaults"
{
    const config = tls.RedirectHttpConfig{};
    try std.testing.expect(config.enabled == true);
    try std.testing.expect(config.port == 80);
    try std.testing.expect(config.to == null);
    try std.testing.expect(config.exclude.len == 0);
}

test "TlsVersion enum"
{
    _ = tls.TlsVersion.tls_1_2;
    _ = tls.TlsVersion.tls_1_3;
}

test "ClientAuth enum"
{
    _ = tls.ClientAuth.none;
    _ = tls.ClientAuth.request;
    _ = tls.ClientAuth.require;
}

test "CertSource union"
{
    const file_src = tls.CertSource{ .file_path = "cert.pem" };
    try std.testing.expectEqualStrings("cert.pem", file_src.file_path);

    const pem_src = tls.CertSource{ .pem_bytes = "-----BEGIN CERT-----" };
    try std.testing.expectEqualStrings("-----BEGIN CERT-----", pem_src.pem_bytes);
}

test "KeySource union"
{
    const file_src = tls.KeySource{ .file_path = "key.pem" };
    try std.testing.expectEqualStrings("key.pem", file_src.file_path);
}
