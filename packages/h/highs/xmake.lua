package("highs")
    set_homepage("https://github.com/ERGO-Code/HiGHS")
    set_description("Linear optimization software")
    set_license("MIT")

    add_urls("https://github.com/ERGO-Code/HiGHS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ERGO-Code/HiGHS.git")

    add_versions("v1.5.3", "ce1a7d2f008e60cc69ab06f8b16831bd0fcd5f6002d3bbebae9d7a3513a1d01d")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_includedirs("include", "include/highs")

    add_deps("cmake", "zlib >=1.2.3")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCI=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Highs_addCol", {includes = "highs/interfaces/highs_c_api.h"}))
    end)
