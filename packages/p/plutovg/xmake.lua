package("plutovg")
    set_homepage("https://github.com/sammycage/plutovg")
    set_description("Tiny 2D vector graphics library in C")
    set_license("MIT")

    add_urls("https://github.com/sammycage/plutovg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/plutovg.git")

    add_versions("v0.0.9", "462a07ef38ecb2c3ed4404a675a7ed9b65002b5c9065b8b7fd6e4b808eef0fbd")
    add_versions("v0.0.8", "090dd5d38e04e0900bf6843b2b38ce7108cab815c1b5496c934af65c51965618")
    add_versions("v0.0.7", "31e264b6f451a0d18335d1596817c2b7f58e2fc6efeb63aac0ff9a7fbfc07c00")
    add_versions("v0.0.6", "3be0e0d94ade3e739f60ac075c88c2e40d84a0ac05fc3ff8c7c97d0749e9a82b")
    add_versions("v0.0.1", "32b8f3501e3964f288f277a607fa87b512466651")

    add_deps("cmake")

    add_includedirs("include", "include/plutovg")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "PLUTOVG_BUILD_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {"-DPLUTOVG_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "plutovg.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plutovg_surface_create", {includes = "plutovg/plutovg.h"}))
    end)
