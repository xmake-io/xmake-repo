package("libmpeg2")
    set_homepage("https://libmpeg2.sourceforge.io")
    set_description("MPEG-1 and MPEG-2 stream decoding library")
    set_license("GPL-2.0-or-later")

    add_urls("https://libmpeg2.sourceforge.io/files/libmpeg2-$(version).tar.gz",
             "https://github.com/cisco-open-source/libmpeg2.git")

    add_versions("0.5.1", "dee22e893cb5fc2b2b6ebd60b88478ab8556cb3b93f9a0d7ce8f3b61851871d4")

    add_patches("0.5.1", "patches/0.1.2/dx.patch", "cf2474cbc42dfdcdc4241bf9eb5708a4e697e83f0ff513986b2e60281dd20b50")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if not is_host("windows") then
        add_deps("autoconf", "automake", "libtool")
    end

    on_load(function (package)
        if package:is_arch("arm.*") then
            package:add("deps", "nasm")
        end

        if package:is_plat("windows") then
            if package:has_tool("cxx", "clang", "clang_cl") then
                if package:config("tools") then
                    package:add("deps", "strings_h", {private = true})
                end
            else
                if package:is_arch("x64") then
                    package:add("deps", "mingw-w64")
                else
                    package:add("deps", "llvm-mingw")
                end
                package:config_set("shared", true)
            end
        end
    end)

    on_install("!android or android@!windows", function (package)
        if not is_host("windows")then
            -- Generate config.h by autotools
            local configs = {"--disable-dependency-tracking"}
            if not package:is_debug() then
                table.insert(configs, "--disable-debug")
            end
            import("package.tools.autoconf").configure(package, configs)
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_install("windows", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        if package:has_tool("cxx", "clang", "clang_cl") then
            import("package.tools.xmake").install(package, {tools = package:config("tools")})
        else
            local arch_prev = package:arch()
            local plat_prev = package:plat()
            package:plat_set("mingw")
            package:arch_set(os.arch())

            import("package.tools.xmake").install(package, {tools = package:config("tools")})

            package:plat_set(plat_prev)
            package:arch_set(arch_prev)

            if package:config("shared") then
                import("utils.platform.gnu2mslib")

                gnu2mslib("mpeg2.lib", "mpeg2.def", {plat = package:plat(), arch = package:arch()})
                os.vcp("mpeg2.lib", package:installdir("lib"))
                os.rm(package:installdir("lib", "libmpeg2.dll.a"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpeg2_init", {includes = {"inttypes.h", "mpeg2dec/mpeg2.h"}}))
    end)
