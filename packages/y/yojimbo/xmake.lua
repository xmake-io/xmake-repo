package("yojimbo")
    set_homepage("https://github.com/mas-bandwidth/yojimbo")
    set_description("A network library for client/server games")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mas-bandwidth/yojimbo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mas-bandwidth/yojimbo.git")

    add_versions("v1.2.5", "0bbac01643f47f4167c884b88a10ed64b327eb4c6cae920551d7bcd447f1e292")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("libsodium")

    if is_plat("windows") and is_arch("arm64") then
        add_defines("SERIALIZE_LITTLE_ENDIAN")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "iphlpapi", "qwave")
    end

    on_install("!wasm and !bsd", function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.release", "mode.debug")

        add_requires("libsodium")
        add_includedirs(".", "include", "tlsf", "netcode", "reliable", "serialize", {public = true})

        if is_plat("windows") and is_arch("arm64") then
            add_defines("SERIALIZE_LITTLE_ENDIAN")
        end

        if is_mode("release") then
            add_defines("YOJIMBO_RELEASE", "NETCODE_RELEASE", "RELIABLE_RELEASE")
        elseif is_mode("debug") then
            add_defines("YOJIMBO_DEBUG", "NETCODE_DEBUG", "RELIABLE_DEBUG")
        end

        target("yojimbo")
            set_kind("$(kind)")
            add_files("source/**.cpp", "netcode/netcode.c", "reliable/reliable.c", "tlsf/tlsf.c")
            add_headerfiles("include/(**.h)", "serialize/(**.h)")
            add_packages("libsodium")

            if is_plat("windows", "mingw") then
                add_syslinks("ws2_32", "iphlpapi", "qwave")
            end
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
