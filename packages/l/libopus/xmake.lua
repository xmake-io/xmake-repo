package("libopus")

    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")

    set_urls("https://archive.mozilla.org/pub/opus/opus-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/opus.git")

    add_versions("1.3.1", "65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d")
    add_patches("1.3.1", path.join(os.scriptdir(), "patches", "1.3.1", "cmake.patch"), "79fba5086d7747d0441f7f156b88e932b662e2d2ccd825279a5a396a2840d3a2")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        if package:is_plat("mingw") then
            -- Disable stack protection on MinGW since it causes link errors
            table.insert(configs, "-DOPUS_STACK_PROTECTOR=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opus_encoder_create", {includes = "opus/opus.h"}))
    end)
