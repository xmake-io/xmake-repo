package("libopus")

    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")

    set_urls("https://gitlab.xiph.org/xiph/opus/-/archive/v$(version)/opus-v$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/opus.git",
             "https://github.com/xiph/opus.git")

    add_versions("1.4", "cf7c31577c384e1dc17a6f57e8460e520d135ab9e0b9068543dd657e25e7da1f")
    add_versions("1.3.1", "a4ef56e2c8fce5dba63f6db1f671e3fa5b18299d953975b6636fee211ddc882a")
    add_patches("1.3.1", path.join(os.scriptdir(), "patches", "1.3.1", "cmake.patch"), "79fba5086d7747d0441f7f156b88e932b662e2d2ccd825279a5a396a2840d3a2")

    add_configs("avx", { description = "AVX supported", default = true, type = "boolean" })
    add_configs("check_avx", { description = "Does runtime check for AVX support", default = true, type = "boolean" })

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        table.insert(configs, "-DAVX_SUPPORTED=" .. (package:config("avx") and "ON" or "OFF"))
        table.insert(configs, "-DOPUS_X86_MAY_HAVE_AVX=" .. (package:config("check_avx") and "ON" or "OFF"))
        if package:is_plat("mingw", "wasm") then
            -- Disable stack protection on MinGW and wasm since it causes link errors
            table.insert(configs, "-DOPUS_STACK_PROTECTOR=OFF")
        elseif package:is_plat("android") then
            table.insert(configs, "-DRUNTIME_CPU_CAPABILITY_DETECTION=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opus_encoder_create", {includes = "opus/opus.h"}))
    end)
