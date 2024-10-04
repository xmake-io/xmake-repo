package("gperftools")

    set_homepage("https://github.com/gperftools/gperftools")
    set_description("gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gperftools/gperftools/archive/refs/tags/gperftools-$(version).tar.gz")
    add_versions("2.16", "f12624af5c5987f2cc830ee534f754c3c5961eec08004c26a8b80de015cf056f")
    add_versions("2.15", "c69fef855628c81ef56f12e3c58f2b7ce1f326c0a1fe783e5cae0b88cbbe9a80")
    add_versions("2.14", "6b561baf304b53d0a25311bd2e29bc993bed76b7c562380949e7cb5e3846b299")
    add_versions("2.13", "4882c5ece69f8691e51ffd6486df7d79dbf43b0c909d84d3c0883e30d27323e7")
    add_versions("2.12", "fb611b56871a3d9c92ab0cc41f9c807e8dfa81a54a4a9de7f30e838756b5c7c6")
    add_versions("2.11", "8ffda10e7c500fea23df182d7adddbf378a203c681515ad913c28a64b87e24dc")
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
