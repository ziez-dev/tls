const std = @import("std");
const ziez = @import("ziez");
const tls = @import("tls.zig");

pub const TlsConfig = tls.TlsConfig;
pub const TlsVersion = tls.TlsVersion;
pub const ClientAuth = tls.ClientAuth;
pub const CipherSuite = tls.CipherSuite;
pub const CertSource = tls.CertSource;
pub const KeySource = tls.KeySource;
pub const ClientCertInfo = tls.ClientCertInfo;
pub const RedirectHttpConfig = tls.RedirectHttpConfig;

pub const TlsSetupConfig = struct {
    tls: TlsConfig,
    redirect: ?RedirectHttpConfig = null,
};

/// Registers TLS and optional HTTP→HTTPS redirect on the app.
pub fn setup(app: *ziez.App, config: TlsSetupConfig) !void {
    const owned_cfg = try app.allocator.create(TlsConfig);
    owned_cfg.* = config.tls;
    app.registerTls(
        owned_cfg,
        tls.createRuntimeFn,
        tls.destroyRuntimeFn,
        tls.freeConfigFn,
        tls.reloadRuntimeFn,
        tls.handleTlsConnection,
    );
    if (config.redirect) |redir| {
        const owned_redir = try app.allocator.create(RedirectHttpConfig);
        owned_redir.* = redir;
        app.registerRedirectHttp(owned_redir, tls.freeRedirectConfigFn, tls.runRedirectListenerFn);
    }
}
