package("zfp")

    set_homepage("https://computing.llnl.gov/projects/zfp")
    set_description("zfp is a compressed format for representing multidimensional floating-point and integer arrays.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/LLNL/zfp/releases/download/$(version)/zfp-$(version).tar.gz")
    add_versions("1.0.1", "ca0f7b4ae88044ffdda12faead30723fe83dd8f5bb0db74125df84589e60e52b")
    add_versions("0.5.5", "fdf7b948bab1f4e5dccfe2c2048fd98c24e417ad8fb8a51ed3463d04147393c5")

    add_patches("0.5.5", path.join(os.scriptdir(), "patches", "0.5.5", "msvc.patch"), "5934c3fcd2abc64857c89c8dc16a2af855ab278e935e8a259bbcea89ddfe9a52")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "ZFP_SHARED_LIBS")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DZFP_WITH_OPENMP=OFF", "-DBUILD_TESTING=OFF", "-DCMAKE_INSTALL_LIBDIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zfp_field_3d", {includes = "zfp.h"}))
    end)
