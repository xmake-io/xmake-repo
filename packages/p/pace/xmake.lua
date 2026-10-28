package("pace")
    set_homepage("https://github.com/TabNahida/PACE")
    set_description("Parallel Async Coroutine Engine: C++20 coroutine networking from sockets to HTTP/3.")
    set_license("MIT")

    add_urls("https://github.com/TabNahida/PACE/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/TabNahida/PACE.git")
    add_versions("0.4.0", "46957eec8edaecc1d0806810f9114a8bfd3af685dad44018579288151afbeed6")
    add_versions("0.3.1", "8688313d3051cfa9f034ae1ec34d0def94677754fb4336ccf7881ebfa3b95d39")
    add_versions("0.3.0", "b55a2ffeb917295159de7c8e753a7c8735a51a3ab7429612dde1a0f5b526a831")

    add_configs("shared", {description = "Build shared libraries.", default = false, type = "boolean", readonly = true})
    add_configs("http1", {description = "Enable HTTP/1.0 and HTTP/1.1.", default = true, type = "boolean"})
    add_configs("websocket", {description = "Enable WebSocket.", default = true, type = "boolean"})
    add_configs("tls", {description = "Enable TLS/HTTPS with OpenSSL.", default = false, type = "boolean"})
    add_configs("dns", {description = "Enable asynchronous DNS with c-ares.", default = false, type = "boolean"})
    add_configs("quic", {description = "Enable QUIC (POSIX only).", default = false, type = "boolean"})
    add_configs("http2", {description = "Enable HTTP/2 with nghttp2.", default = false, type = "boolean"})
    add_configs("http3", {description = "Enable HTTP/3 and QUIC (POSIX only).", default = false, type = "boolean"})
    add_configs("profiling", {description = "Enable intrusive per-thread stage timings.", default = false, type = "boolean"})

    on_load(function (package)
        local quic = package:config("quic") or package:config("http3")
        if quic and package:is_plat("windows", "mingw") then
            raise("PACE QUIC/HTTP3 currently require a POSIX platform")
        end

        if package:is_plat("windows") and package:is_arch("arm64") and package:config("tls") then
            raise("package(pace): Windows ARM64 TLS needs the corrected OpenSSL recipe in the PACE source build; the public openssl3 dependency is not yet compatible")
        end
        if package:config("tls") or quic then
            package:add("deps", "openssl3 3.5.7")
        end
        if package:config("dns") then
            package:add("deps", "c-ares 1.34.8")
        end
        if package:config("http2") then
            package:add("deps", "nghttp2 1.70.0")
        end
        if package:config("http3") then
            package:add("deps", "nghttp3 v1.18.0")
        end

        -- Static libraries must precede the PACE modules they depend on.
        for _, name in ipairs({"http3", "http2", "http1", "websocket", "quic", "tls", "dns"}) do
            if package:config(name) or (name == "quic" and quic) then
                package:add("links", "pace_" .. name)
                package:add("defines", "PACE_HAS_" .. name:upper())
            end
        end
        package:add("links", "pace_net", "pace_runtime")
        if package:config("profiling") then
            package:add("defines", "PACE_ENABLE_PROFILING")
        end
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "ws2_32", "bcrypt")
            package:add("defines", "WIN32_LEAN_AND_MEAN", "NOMINMAX", "_WIN32_WINNT=0x0A00")
        else
            package:add("syslinks", "pthread")
        end
    end)

    on_install("linux", "macosx", "bsd", "windows", "mingw", function (package)
        local configs = {
            cxxstandard = "cxx20",
            tests = false,
            examples = false,
            benchmarks = false,
            components = false,
            scaling = false
        }
        for _, name in ipairs({"http1", "websocket", "tls", "dns", "quic", "http2", "http3", "profiling"}) do
            configs[name] = package:config(name)
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                pace::run([]() -> pace::task<void> { co_await pace::yield(); });
            #ifdef PACE_HAS_HTTP1
                pace::http::app app;
                app.get("/", [] { return pace::http::text("ok"); });
                auto request = pace::http::get("http://127.0.0.1/");
            #endif
            }
        ]]}, {configs = {languages = "c++20"}, includes = "pace/pace.hpp"}))
    end)
