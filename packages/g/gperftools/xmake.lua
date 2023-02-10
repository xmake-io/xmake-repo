package("gperftools")

    set_homepage("https://github.com/gperftools/gperftools")
    set_description("gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gperftools/gperftools/archive/refs/tags/gperftools-$(version).tar.gz")
    add_versions("2.10", "b0dcfe3aca1a8355955f4b415ede43530e3bb91953b6ffdd75c45891070fe0f1")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = is_plat("windows")})
    if is_plat("linux") then
        add_configs("unwind", {description = "Enable libunwind support.", default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_load("linux", function (package)
        if package:config("unwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-Dgperftools_build_benchmark=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DGPERFTOOLS_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        if package:is_plat("linux") then
            table.insert(configs, "-Dgperftools_enable_libunwind=" .. (package:config("unwind") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tc_version", {includes = "gperftools/tcmalloc.h"}))
    end)
