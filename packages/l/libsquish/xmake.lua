package("libsquish")
    set_homepage("https://sourceforge.net/projects/libsquish/")
    set_description("The libSquish library compresses images with the DXT standard (also known as S3TC).")
    set_license("MIT")

    add_urls("https://sourceforge.net/projects/libsquish/files/libsquish-$(version).tgz")
    add_versions("1.15", "628796eeba608866183a61d080d46967c9dda6723bc0a3ec52324c85d2147269")

    add_configs("openmp", {description = "Enable OpenMP build.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_SQUISH_EXTRA=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SQUISH_WITH_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp(package:buildir() .. "/**.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace squish;
                u8 input[4*16];
                u8 output[4*16];
                u8 block[16];
                Compress( input, block, kDxt1 );
                Decompress( output, block, kDxt1 );
            }
        ]]}, {configs = {languages = "c++11"}, includes = "squish.h"}))
    end)
