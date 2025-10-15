package("freexl")
    set_homepage("https://www.gaia-gis.it/fossil/freexl/index")
    set_description("FreeXL is an open source library to extract valid data from within an Excel (.xls) spreadsheet.")
    set_license("MPL-1.0")
    
    add_urls("https://www.gaia-gis.it/gaia-sins/freexl-sources/freexl-$(version).tar.gz")

    add_versions("2.0.0", "176705f1de58ab7c1eebbf5c6de46ab76fcd8b856508dbd28f5648f7c6e1a7f0")

    add_deps("libiconv", "expat", "minizip")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libfreexl")
    elseif is_plat("linux") then
        add_extsources("pacman::libfreexl", "apt::libfreexl-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::freexl")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 23, "package(freexl) dep(minizip) require ndk api level >= 23")
        end)
    end

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            io.replace("headers/freexl.h", "#define FREEXL_DECLARE extern", "#define FREEXL_DECLARE __declspec(dllimport)", {plain = true})
        end
        if not package:is_plat("windows") then
            os.touch("src/config.h")
        end
        io.writefile("xmake.lua", string.format([[
            option("ver", {default = "%s"})
            add_rules("mode.debug", "mode.release")
            add_requires("libiconv", "expat", "minizip")
            target("freexl")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_includedirs(".", "headers")
                add_headerfiles("headers/freexl.h")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("DLL_EXPORT")
                end
                if is_plat("linux", "bsd") then
                    add_syslinks("m")
                end
                add_packages("libiconv", "expat", "minizip")
                if has_config("ver") then
                    add_defines("VERSION=\"" .. get_config("ver") .. "\"")
                    set_version(get_config("ver"), {soname = true})
                end
        ]], package:version_str()))
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("freexl_open", {includes = "freexl.h"}))
    end)
