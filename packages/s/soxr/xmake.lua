package("soxr")
    set_homepage("https://sourceforge.net/projects/soxr")
    set_description("The SoX Resampler library libsoxr performs fast, high-quality one-dimensional sample rate conversion.")
    set_license("LGPL-2.1")

    add_urls("https://salsa.debian.org/multimedia-team/libsoxr/-/archive/upstream/$(version)/libsoxr-upstream-$(version).zip")

    add_versions("0.1.3", "b755c59aa3eebeb7fb5591fc606bf56f4214d86d3668886ac6df48d3a9552817")

    add_configs("openmp",   {description = "Include OpenMP threading.", default = false, type = "boolean"})
    add_configs("lsr",      {description = "Include a `libsamplerate'-like interface.", default = true, type = "boolean"})
    if is_plat("mingw") and is_subhost("macosx") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    elseif is_plat("linux") and is_arch("arm64") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:config("lsr") then
            package:add("links", "soxr-lsr", "soxr")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "SOXR_DLL")
        end
        if package:is_plat("mingw") and not package:config("shared") then
            package:add("defines", "SOXR_DLL")
            package:add("defines", "soxr_EXPORTS")
            if package:config("lsr") then
                package:add("defines", "soxr_lsr_EXPORTS")
            end
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF"
        }
        -- support for ndk >= r27 https://github.com/android/ndk/issues/2032
        table.insert(configs, "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW")
        -- Disable SIMD based resample engines for Apple Silicon and iOS ARMv8 architecture
        if package:is_plat("macosx", "iphoneos") and package:is_arch("arm.*") then
            table.insert(configs, "-DWITH_CR32S=OFF")
            table.insert(configs, "-DWITH_CR64S=OFF")
        end
        table.insert(configs, "-DWITH_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_LSR_BINDINGS=" .. (package:config("lsr") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <soxr.h>
            #include <stdio.h>
            void test() {
                printf("soxr version: %s\n", soxr_version());
            }
        ]]}, {configs = {languages = "c11"}}))
        if package:config("lsr") then
            assert(package:check_csnippets({test = [[
                #include <soxr-lsr.h>
                #include <stdio.h>
                void test() {
                    printf("soxr-lsr version: %s\n", src_get_version());
                }
            ]]}, {configs = {languages = "c11"}}))
        end
    end)
