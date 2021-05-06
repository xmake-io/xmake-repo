package("filament")

    set_homepage("https://google.github.io/filament/")
    set_description("Filament is a real-time physically-based renderer written in C++.")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/filament/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/filament.git")
    add_versions("v1.9.23", "f353167208df8c2c6cf56175e863bd4d9e36d1655df7bcae36a85c107e009107")

    add_configs("ninja", {description = "Use ninja to build the library.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load("windows|x64", function (package)
        if package:config("ninja") then
            package:add("deps", "ninja")
        end
    end)

    on_install("windows|x64", function (package)
        local configs = {"-DFILAMENT_ENABLE_JAVA=OFF", "-DFILAMENT_SKIP_SAMPLES=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        local opt = {buildir = os.tmpdir()}
        if package:config("ninja") then
            opt.cmake_generator = "Ninja"
        end
        import("package.tools.cmake").install(package, configs, opt)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("filament::Engine", {configs = {languages = "c++11"}, includes = "filament/Engine.h"}))
    end)
