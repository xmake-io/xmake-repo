package("charls")
    set_homepage("https://github.com/team-charls/charls")
    set_description("CharLS, a C++ JPEG-LS library implementation")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/team-charls/charls/archive/refs/tags/$(version).tar.gz",
             "https://github.com/team-charls/charls.git")

    add_versions("2.4.2", "d1c2c35664976f1e43fec7764d72755e6a50a80f38eca70fcc7553cad4fe19d9")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DCHARLS_BUILD_TESTS=OFF",
            "-DCHARLS_BUILD_AFL_FUZZ_TEST=OFF",
            "-DCHARLS_BUILD_LIBFUZZER_FUZZ_TEST=OFF",
            "-DCHARLS_BUILD_SAMPLES=OFF",
            "-DCHARLS_INSTALL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if not package:config("shared") then
            package:add("defines", "CHARLS_STATIC")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("charls_jpegls_encoder_create", {includes = "charls/charls.h"}))
    end)
