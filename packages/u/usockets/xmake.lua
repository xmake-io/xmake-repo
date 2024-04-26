package("usockets")

    set_homepage("https://github.com/uNetworking")
    set_description("µSockets is the non-blocking, thread-per-CPU foundation library used by µWebSockets. It provides optimized networking - using the same opaque API (programming interface) across all supported transports, event-loops and platforms.")

    set_urls(             "https://github.com/uNetworking/uSockets/archive/refs/tags/$(version).zip")

    add_versions("v0.8.8", "9d132b57fa9498a3be5d55881d4f782eca5008eea598b3e0639904f487592cbe")
    add_deps("libuv","openssl")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("libuv")
            add_packages("libuv")

            add_defines("LIBUS_USE_OPENSSL")
            add_requires("openssl")
            add_packages("openssl")

            target("usockets")
                set_kind("static")
                set_languages("cxx20")

                add_files("src/**.cpp", "src/**.c")
                add_includedirs("src")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp("src/libusockets.h", package:installdir("include"))
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("us_create_socket_context(0,0,0,struct us_socket_context_options_t{0})", {includes = {"libusockets.h"}}))
    end)