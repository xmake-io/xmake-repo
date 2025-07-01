package("libebur128")
    set_homepage("https://github.com/jiixyj/libebur128")
    set_description("A library implementing the EBU R128 loudness standard.")
    set_license("MIT")

    add_urls("https://github.com/jiixyj/libebur128/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jiixyj/libebur128.git")

    add_versions("v1.2.6", "baa7fc293a3d4651e244d8022ad03ab797ca3c2ad8442c43199afe8059faa613")

    add_deps("cmake")

    on_install(function (package)
        io.replace("ebur128/ebur128.c", [[#warning "manual FTZ is being used, please enable SSE2 (-msse2 -mfpmath=sse)"]], "", {plain = true})
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ebur128_init", {includes = "ebur128.h"}))
    end)
