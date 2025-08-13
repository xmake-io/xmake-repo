package("yojimbo")
    set_homepage("https://github.com/mas-bandwidth/yojimbo")
    set_description("A network library for client/server games")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mas-bandwidth/yojimbo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mas-bandwidth/yojimbo.git")

    add_versions("v1.2.3", "3cf69218654df0e4da904b0a291e63e7470a7b6a6350f599f84f862e98f7c707")

    add_deps("libsodium")

    if os.host() == "windows" then
        local host_arch = os.arch()
        if is_plat("windows") then 
             if (host_arch == "x86" or host_arch == "x64") and is_arch("arm64") then 
                add_defines("SERIALIZE_LITTLE_ENDIAN")
             end
        end
    end

    on_install(function (package)
        import("package.tools.xmake")

        io.writefile("xmake.lua", [[
        add_rules("mode.release", "mode.debug")

        add_requires("libsodium")
        add_includedirs(".", "include", "tlsf", "netcode", "reliable", "serialize", {public = true})

        target("yojimbo")
            set_kind("static")
            add_files("source/**.cpp", "netcode/netcode.c", "reliable/reliable.c", "tlsf/tlsf.c")
            add_headerfiles("include/**.h", "tlsf/**.h", "netcode/**.h", "reliable/**.h", "serialize/**.h")
            add_packages("libsodium")
        ]])

        xmake.install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                InitializeYojimbo();
            }
        ]]}, {includes = "yojimbo.h"}))
    end)
