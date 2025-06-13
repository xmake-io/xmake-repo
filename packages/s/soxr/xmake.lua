package("soxr")
    set_homepage("https://sourceforge.net/projects/soxr")
    set_description("The SoX Resampler library libsoxr performs fast, high-quality one-dimensional sample rate conversion.")
    set_license("LGPL-2.1")

    add_urls("https://downloads.sourceforge.net/project/soxr/soxr-$(version)-Source.tar.xz",
             "https://deac-fra.dl.sourceforge.net/project/soxr/soxr-$(version)-Source.tar.xz",
             "https://deac-riga.dl.sourceforge.net/project/soxr/soxr-$(version)-Source.tar.xz", {alias = "sourceforge"})

    add_urls("https://sourceforge.net/code-snapshots/git/s/so/soxr/code.git/soxr-code-$(version).zip", {alias = "snapshot", version = function (version)
        local versions = {
            ["0.1.3"] = "945b592b70470e29f917f4de89b4281fbbd540c0"
        }
        return versions[tostring(version)]
    end})

    add_versions("snapshot:0.1.3", "b797a5d23078be234e520af1041b5e11b49864696d56f0d0b022a0349d1e8d1b")
    add_versions("sourceforge:0.1.3", "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889")

    add_configs("openmp",   {description = "Include OpenMP threading.", default = false, type = "boolean"})
    add_configs("lsr",      {description = "Include a `libsamplerate'-like interface.", default = true, type = "boolean"})

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
