package("xor_singleheader")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/FastFilter/xor_singleheader")
    set_description("Header-only binary fuse and xor filter library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/FastFilter/xor_singleheader/archive/refs/tags/$(version).tar.gz",
             "https://github.com/FastFilter/xor_singleheader.git")

    add_versions("v2.1.0", "8bd366d0e966e5659b35131669cfff31c7beccf74b9c258ea189b45e6592a9d8")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake")
    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        io.replace("CMakeLists.txt", "add_subdirectory(benchmarks)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("binary_fuse_cmpfunc", {includes = "binaryfusefilter.h"}))
    end)
