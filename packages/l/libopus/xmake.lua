package("libopus")

    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")

    set_urls("https://github.com/xiph/opus/archive/v$(version).tar.gz",
             "https://github.com/xiph/opus.git")

    add_versions("1.3.1", "4834a8944c33a7ecab5cad9454eeabe4680ca1842cb8f5a2437572dbf636de8f")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:has_cfuncs("opus_encoder_create", {includes = "opus.h"}))
    end)
