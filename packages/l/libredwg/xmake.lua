package("libredwg")
    set_homepage("https://github.com/LibreDWG/libredwg")
    set_description("This is a library to allow reading data from a DWG file.")

    add_urls("https://github.com/LibreDWG/libredwg.git")
    add_versions("0.13.3", "97c7225596c17430b82fd0161e7eff6beb5b1034")

    add_deps("cmake")

    on_install("windows", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DDISABLE_WERROR=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dwg_rgb_palette_index", {includes = "dwg.h"}))
    end)
