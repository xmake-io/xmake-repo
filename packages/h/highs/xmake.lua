package("highs")
    set_homepage("https://github.com/ERGO-Code/HiGHS")
    set_description("Linear optimization software")
    set_license("MIT")

    add_urls("https://github.com/ERGO-Code/HiGHS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ERGO-Code/HiGHS.git")

    add_versions("v1.8.0", "e184e63101cf19688a02102f58447acc7c021d77eef0d3475ceaceb61f035539")
    add_versions("v1.7.2", "5ff96c14ae19592d3568e9ae107624cbaf3409d328fb1a586359f0adf9b34bf7")
    add_versions("v1.7.1", "65c6f9fc2365ced42ee8eb2d209a0d3a7942cd59ff4bd20464e195c433f3a885")
    add_versions("v1.7.0", "d10175ad66e7f113ac5dc00c9d6650a620663a6884fbf2942d6eb7a3d854604f")
    add_versions("v1.5.3", "ce1a7d2f008e60cc69ab06f8b16831bd0fcd5f6002d3bbebae9d7a3513a1d01d")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_includedirs("include", "include/highs")

    add_deps("cmake", "zlib >=1.2.3")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "mingw", "msys", "iphoneos", "cross", "wasm", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCI=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Highs_addCol", {includes = "highs/interfaces/highs_c_api.h"}))
    end)
