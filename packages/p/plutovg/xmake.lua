package("plutovg")
    set_homepage("https://github.com/sammycage/plutovg")
    set_description("Tiny 2D vector graphics library in C")
    set_license("MIT")

    add_urls("https://github.com/sammycage/plutovg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/plutovg.git")

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
