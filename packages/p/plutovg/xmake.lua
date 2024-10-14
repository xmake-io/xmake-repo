package("plutovg")
    set_homepage("https://github.com/sammycage/plutovg")
    set_description("Tiny 2D vector graphics library in C")
    set_license("MIT")

    add_urls("https://github.com/sammycage/plutovg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/plutovg.git")

    add_versions("v0.0.7", "31e264b6f451a0d18335d1596817c2b7f58e2fc6efeb63aac0ff9a7fbfc07c00")
    add_versions("v0.0.6", "3be0e0d94ade3e739f60ac075c88c2e40d84a0ac05fc3ff8c7c97d0749e9a82b")
    add_versions("v0.0.1", "32b8f3501e3964f288f277a607fa87b512466651")

    add_deps("cmake")

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "PLUTOVG_BUILD_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {"-DPLUTOVG_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plutovg_surface_create", {includes = "plutovg/plutovg.h"}))
    end)
