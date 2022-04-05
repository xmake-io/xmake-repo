package("lightgbm")

    set_homepage("https://github.com/microsoft/LightGBM")
    set_description("LightGBM is a gradient boosting framework that uses tree based learning algorithms.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/LightGBM/releases/download/v$(version)/lightgbm-$(version).tar.gz")
    add_versions("3.2.1", "bd98e3b501b4c24dc127f4ad93e467f42923fe3eefa99e143b5b93158f024395")

    add_configs("gpu", {description = "Enable GPU-accelerated training.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load("windows|x64", "linux", function (package)
        if package:config("gpu") then
            package:add("deps", "opencl")
            package:add("deps", "boost", {configs = {filesystem = true, system = true}})
        end
    end)

    on_install("windows|x64", "linux", function (package)
        os.cd("compile")
        local configs = {"-DBoost_USE_STATIC_LIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("LightGBM::ChunkedArray<int>", {includes = "LightGBM/utils/chunked_array.hpp"}))
    end)
