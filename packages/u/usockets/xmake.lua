package("usockets")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/uNetworking/uSockets")
    set_description("Optimized TCP, TLS, QUIC & HTTP3 transports.")
    set_license("Apache-2.0")

    add_urls("https://github.com/uNetworking/uSockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uNetworking/uSockets.git")
    add_versions("v0.8.1", "3b33b5924a92577854e2326b3e2d393849ec00beb865a1271bf24c0f210cc1d6")

    on_install("linux", "macosx", "bsd", function (package)
    end)
