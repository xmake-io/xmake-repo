package("zlib-ng")

    set_homepage("https://github.com/zlib-ng/zlib-ng")
    set_description("zlib replacement with optimizations for next generation systems.")

    add_urls("https://github.com/zlib-ng/zlib-ng.git")

    add_versions("2.0.5", "c69f78bc5e18a0f6de2dcbd8af863f59a14194f0")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DZLIB_COMPAT=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DINC_INSTALL_DIR=" .. package:installdir("include"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
