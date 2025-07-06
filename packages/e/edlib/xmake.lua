package("edlib")
    set_homepage("http://martinsos.github.io/edlib")
    set_description("Lightweight, super fast C/C++ (& Python) library for sequence alignment using edit (Levenshtein) distance.")
    set_license("MIT")

    add_urls("https://github.com/Martinsos/edlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Martinsos/edlib.git")

    add_versions("v1.2.7", "8767bc1b04a1a67282d57662e5702c4908996e96b1753b5520921ff189974621")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DEDLIB_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DEDLIB_BUILD_UTILITIES=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "EDLIB_SHARED")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("edlibAlign", {includes = "edlib.h"}))
    end)
