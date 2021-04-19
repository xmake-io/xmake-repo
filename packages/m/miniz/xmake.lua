package("miniz")

    set_homepage("https://github.com/richgel999/miniz/")
    set_description("miniz: Single C source file zlib-replacement library")
    set_license("MIT")

    add_urls("https://github.com/richgel999/miniz/archive/refs/tags/2.1.0.tar.gz",
             "https://github.com/richgel999/miniz.git")
    add_versions("2.1.0", "95f9b23c92219ad2670389a23a4ed5723b7329c82c3d933b7047673ecdfc1fea")

    on_install(function (package)
        io.writefile("miniz_export.h", "#define MINIZ_EXPORT")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("miniz")
                set_kind("static")
                add_files("miniz.c", "miniz_zip.c", "miniz_tinfl.c", "miniz_tdef.c")
                add_headerfiles("miniz.h", "miniz_common.h", "miniz_zip.h", "miniz_tinfl.h", "miniz_tdef.h")
        ]])
        local configs = {}
        if package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mz_compress", {includes = "miniz.h"}))
    end)
