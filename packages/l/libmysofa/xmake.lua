package("libmysofa")
    set_homepage("https://github.com/hoene/libmysofa")
    set_description("Reader for AES SOFA files to get better HRTFs")

    add_urls("https://github.com/hoene/libmysofa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hoene/libmysofa.git")

    add_versions("v1.3.2", "6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76")

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
