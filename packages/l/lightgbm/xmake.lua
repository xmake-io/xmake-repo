package("lightgbm")
    set_homepage("https://github.com/microsoft/LightGBM")
    set_description("LightGBM is a gradient boosting framework that uses tree based learning algorithms.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/LightGBM/releases/download/v$(version)/lightgbm-$(version).tar.gz")
    add_versions("4.4.0", "9e8a7640911481134e60987d5d1e1cd157f430c3b4b38de8d36fc55c302bc299")
    add_versions("4.3.0", "006f5784a9bcee43e5a7e943dc4f02de1ba2ee7a7af1ee5f190d383f3b6c9ebe")
    add_versions("4.2.0", "8a4d051df2ab2218998a16f7712e843ee9e96d8b09ffbfcc18533da127e0da02")
    add_versions("3.3.2", "5d25d16e77c844c297ece2044df57651139bc3c8ad8c4108916374267ac68b64")
    add_versions("3.2.1", "bd98e3b501b4c24dc127f4ad93e467f42923fe3eefa99e143b5b93158f024395")

    add_configs("gpu", {description = "Enable GPU-accelerated training.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load("windows|x64", "linux", function (package)
        if package:config("gpu") then
            package:add("deps", "opencl")
            package:add("deps", "boost", {configs = {filesystem = true, system = true}})
        end
        if package:is_plat("linux") and package:has_tool("cc", "clang", "clangxx") then
            package:add("deps", "libomp")
        end
    end)

    on_install("windows|x64", "linux", function (package)
        if package:version():lt("4.2.0") then
            os.cd("compile")
        end

        local configs = {"-DBoost_USE_STATIC_LIBS=ON", "-DBUILD_CLI=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:is_plat("linux") and package:has_tool("cc", "clang", "clangxx") then
            local libomp = package:dep("libomp"):fetch()
            if libomp then
                local includedirs = table.wrap(libomp.includedirs or libomp.sysincludedirs)
                local libfiles = table.wrap(libomp.libfiles)
                if #includedirs > 0 and #libfiles > 0 then
                    table.insert(configs, "-DOpenMP_C_LIB_NAMES=libomp")
                    table.insert(configs, "-DOpenMP_C_FLAGS=-I" .. includedirs[1])
                    table.insert(configs, "-DOpenMP_CXX_LIB_NAMES=libomp")
                    table.insert(configs, "-DOpenMP_CXX_FLAGS=-I" .. includedirs[1])
                    table.insert(configs, "-DOpenMP_libomp_LIBRARY=" .. table.concat(libfiles, " "))
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("LightGBM::ChunkedArray<int>", {includes = "LightGBM/utils/chunked_array.hpp"}))
    end)
