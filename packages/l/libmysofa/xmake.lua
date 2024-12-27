package("libmysofa")
    set_homepage("https://github.com/hoene/libmysofa")
    set_description("Reader for AES SOFA files to get better HRTFs")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hoene/libmysofa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hoene/libmysofa.git")

    add_versions("v1.3.2", "6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76")

    add_patches("v1.3.2", "patches/v1.3.2/fix-build.patch", "4080272c7b77d41f629bee1abf3b8bfc8ddc76b315761cca89971c0460990b76")

    add_deps("cmake", "zlib")

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DBUILD_STATIC_LIBS=ON")
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysofa_open", {includes = "mysofa.h"}))
    end)
