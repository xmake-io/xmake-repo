package("yojimbo")
    set_homepage("https://github.com/mas-bandwidth/yojimbo")
    set_description("A network library for client/server games")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mas-bandwidth/yojimbo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mas-bandwidth/yojimbo.git")

    add_versions("v1.2.3", "3cf69218654df0e4da904b0a291e63e7470a7b6a6350f599f84f862e98f7c707")

    add_patches("v1.2.3", "patches/v1.2.3/nominmax.patch", "4dfa72b763a7ac06b153a92ebe6e2c1daa55de97852c8f739e0ab17f306c8324")

    add_deps("libsodium")

    if is_plat("windows") and is_arch("arm64") then
        add_defines("SERIALIZE_LITTLE_ENDIAN")
    end

    on_install("!wasm and !bsd",function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.release", "mode.debug")

        add_requires("libsodium")
        add_includedirs(".", "include", "tlsf", "netcode", "reliable", "serialize", {public = true})

        if is_plat("windows") and is_arch("arm64") then
            add_defines("SERIALIZE_LITTLE_ENDIAN")
        end

        if is_mode("release") then
            add_defines("YOJIMBO_RELEASE", "NETCODE_RELEASE", "RELIABLE_RELEASE")
            set_optimize("fastest")
            set_symbols(none)
        end

        if is_mode("debug") then
            add_defines("YOJIMBO_DEBUG", "NETCODE_DEBUG", "RELIABLE_DEBUG")
        end

        target("yojimbo")
            set_kind("static")
            add_files("source/**.cpp", "netcode/netcode.c", "reliable/reliable.c", "tlsf/tlsf.c")
            add_headerfiles("include/**.h", "tlsf/**.h", "netcode/**.h", "reliable/**.h", "serialize/**.h")
            add_packages("libsodium")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                InitializeYojimbo();
            }
        ]]}, {includes = "yojimbo.h"}))
    end)
