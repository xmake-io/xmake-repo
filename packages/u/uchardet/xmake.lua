package("uchardet")

    set_homepage("https://www.freedesktop.org/wiki/Software/uchardet/")
    set_description("uchardet is an encoding detector library, which takes a sequence of bytes in an unknown character encoding without any additional information, and attempts to determine the encoding of the text. ")
    set_license("MPL-1.1")

    add_urls("https://www.freedesktop.org/software/uchardet/releases/uchardet-$(version).tar.xz")
    add_versions("0.0.7", "3fc79408ae1d84b406922fa9319ce005631c95ca0f34b205fad867e8b30e45b1")
    add_versions("0.0.8", "e97a60cfc00a1c147a674b097bb1422abd9fa78a2d9ce3f3fdcc2e78a34ac5f0")

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            if is_plat("windows") then
                add_requires("cgetopt")
            end
            target("uchardet")
                set_kind("$(kind)")
                add_includedirs("src")
                add_headerfiles("src/uchardet.h")
                if is_kind("shared") then
                    add_defines("UCHARDET_SHARED")
                end
                add_defines("BUILDING_UCHARDET")
                add_files("src/*.cpp", "src/LangModels/*.cpp")
            target("uchardet_bin")
                set_kind("binary")
                set_basename("uchardet")
                add_files("src/tools/uchardet.cpp")
                add_deps("uchardet")
                if is_plat("windows") then
                    add_packages("cgetopt")
                end
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("uchardet -v")
        end
        assert(package:has_cfuncs("uchardet_get_charset", {includes = "uchardet.h"}))
    end)