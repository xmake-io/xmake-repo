package("soxr")
    set_homepage("https://sourceforge.net/projects/soxr")
    set_description("The SoX Resampler library libsoxr performs fast, high-quality one-dimensional sample rate conversion.")
    set_license("LGPL-2.1")

    add_urls("https://sourceforge.net/code-snapshots/git/s/so/soxr/code.git/soxr-code-$(version).zip", {alias = "snapshot",
            http_headers = {
                "Referer: https://sourceforge.net/p/soxr/code/ci/0.1.3/tarball?path",
                "Upgrade-Insecure-Requests: 1",
                "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 Edg/138.0.0.0",
                "sec-ch-ua: Not)A;Brand;v=8, Chromium;v=138, Microsoft Edge;v=138",
                "sec-ch-ua-arch: x86",
                "sec-ch-ua-bitness: 64",
                "sec-ch-ua-full-version: 138.0.3351.95",
                "sec-ch-ua-full-version-list: Not)A;Brand;v=8.0.0.0, Chromium;v=138.0.7204.158, Microsoft Edge;v=138.0.3351.95",
                "sec-ch-ua-mobile: ?0",
                "sec-ch-ua-model: ",
                "sec-ch-ua-platform: Windows",
                "sec-ch-ua-platform-version: 19.0.0"
            },
    version = function (version)
        local versions = {
            ["0.1.3"] = "945b592b70470e29f917f4de89b4281fbbd540c0"
        }
        return versions[tostring(version)]
    end})

    add_versions("snapshot:0.1.3", "b797a5d23078be234e520af1041b5e11b49864696d56f0d0b022a0349d1e8d1b")

    add_configs("openmp",   {description = "Include OpenMP threading.", default = false, type = "boolean"})
    add_configs("lsr",      {description = "Include a `libsamplerate'-like interface.", default = true, type = "boolean"})
    if is_plat("mingw") and is_subhost("macosx") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end
    if is_plat("linux") and is_arch("arm64") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
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
