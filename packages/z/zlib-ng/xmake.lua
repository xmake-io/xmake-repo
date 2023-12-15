package("zlib-ng")

    set_homepage("https://github.com/zlib-ng/zlib-ng")
    set_description("zlib replacement with optimizations for next generation systems.")
    set_license("zlib")

    add_urls("https://github.com/zlib-ng/zlib-ng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zlib-ng/zlib-ng.git")
    add_versions("2.0.5", "eca3fe72aea7036c31d00ca120493923c4d5b99fe02e6d3322f7c88dbdcd0085")
    add_versions("2.0.6", "8258b75a72303b661a238047cb348203d88d9dddf85d480ed885f375916fcab6")
    add_versions("2.1.5", "3f6576971397b379d4205ae5451ff5a68edf6c103b2f03c4188ed7075fbb5f04")

    add_deps("cmake")

    on_load(function (package)
        if package:version():eq("2.1.5") then
            if package:is_plat("android") or package:is_arch("arm.*") then
                raise("zlib-ng 2.1.5 not support android and arm.")
            end
        end
    end)

    on_install("windows", "macosx", "linux", "android", "mingw", function (package)
        local configs = {"-DZLIB_COMPAT=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DINC_INSTALL_DIR=" .. package:installdir("include"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("inflate", {includes = "zlib.h"}))
    end)
