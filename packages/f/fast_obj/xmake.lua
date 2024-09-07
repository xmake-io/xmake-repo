package("fast_obj")
    set_homepage("https://github.com/thisistherk/fast_obj")
    set_description("Fast C OBJ parser")
    set_license("MIT")

    add_urls("https://github.com/thisistherk/fast_obj/archive/refs/tags/$(version).tar.gz",
             "https://github.com/thisistherk/fast_obj.git")

    add_versions("v1.3", "f0f175edbe60db2099b3d8266ff0085b21862a17d9a1dc00fd195258c5b622b1")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("fast_obj.h", package:installdir("include"))
            return
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("fast_obj")
                set_kind("$(kind)")
                add_files("fast_obj.c")
                add_headerfiles("fast_obj.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fast_obj_read", {includes = "fast_obj.h"}))
    end)
