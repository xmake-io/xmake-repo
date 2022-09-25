package("bcg729")
    set_homepage("http://linphone.org")
    set_description(" Linphone.org mirror for bcg729 (git://git.linphone.org/bcg729.git)")

    add_urls("https://github.com/BelledonneCommunications/bcg729.git")
    add_versions("1.0.4", "9ada79d7ff53815e85432e7442810a2fd49dbd0e")
    add_versions("1.1.1", "faaa895862165acde6df8add722ba4f85a25007d")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bcg729Decoder", {includes = "bcg729/decoder.h"}))
        assert(package:has_cfuncs("bcg729Encoder", {includes = "bcg729/encoder.h"}))
    end)
