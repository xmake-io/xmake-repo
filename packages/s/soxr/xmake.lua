package("soxr")
    set_homepage("https://sourceforge.net/projects/soxr")
    set_description("High quality audio resampling")
    set_license("LGPL-2.1")

    add_urls("https://downloads.sourceforge.net/project/soxr/soxr-$(version)-Source.tar.xz")
    add_versions("0.1.3", "b111c15fdc8c029989330ff559184198c161100a59312f5dc19ddeb9b5a15889")

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
        if package:config("shared") then
            package:add("defines", "SOXR_DLL")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF"
        }
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
