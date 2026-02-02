package("zimg")
    set_homepage("https://github.com/sekrit-twc/zimg")
    set_description("Scaling, colorspace conversion, and dithering library")
    set_license("WTFPL")

    add_urls("https://github.com/sekrit-twc/zimg/archive/refs/tags/release-$(version).tar.gz")
    add_urls("https://github.com/sekrit-twc/zimg.git", {alias = "git", submodules = false})

    add_versions("3.0.5", "a9a0226bf85e0d83c41a8ebe4e3e690e1348682f6a2a7838f1b8cbff1b799bcf")
    add_versions("3.0.3", "5e002992bfe8b9d2867fdc9266dc84faca46f0bfd931acc2ae0124972b6170a7")

    add_versions("git:3.0.6", "release-3.0.6")

    add_configs("simd", {description = "Enable SIMD", default = true, type = "boolean"})

    if not is_subhost("windows") and not is_plat("windows") then
        add_deps("autotools")
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        if not package:config("simd") then
            table.insert(configs, "--disable-simd")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows or @windows", function (package)
        if package:config("shared") and package:is_plat("windows") then
            io.replace("src/zimg/api/zimg.h", "#define ZIMG_VISIBILITY", "#define ZIMG_VISIBILITY __declspec(dllexport)", {plain = true})
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {simd = package:config("simd")})

        if package:config("shared") and package:is_plat("windows") then
            io.replace("src/zimg/api/zimg.h", "__declspec(dllexport)", "#define ZIMG_VISIBILITY __declspec(dllimport)", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zimg_image_format_default", {includes = "zimg.h"}))
    end)
