package("bcg729")
    set_homepage("http://linphone.org")
    set_description("Bcg729 is an opensource implementation of both encoder and decoder of the ITU G729 Annex A/B speech codec.")

    add_urls("https://github.com/BelledonneCommunications/bcg729/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BelledonneCommunications/bcg729.git")
    add_versions("1.0.4", "94b3542a06cbd96306efc19f959f9febae62806a22599063f82a8c33e989d48b")
    add_versions("1.1.1", "68599a850535d1b182932b3f86558ac8a76d4b899a548183b062956c5fdc916d")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DENABLE_TESTS=OFF"}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DENABLE_SHARED=ON")
            table.insert(configs, "-DENABLE_STATIC=OFF")
        else
            table.insert(configs, "-DENABLE_SHARED=OFF")
            table.insert(configs, "-DENABLE_STATIC=ON")
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bcg729Decoder", {includes = "bcg729/decoder.h"}))
        assert(package:has_cfuncs("bcg729Encoder", {includes = "bcg729/encoder.h"}))
    end)
