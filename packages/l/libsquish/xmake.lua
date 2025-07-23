package("libsquish")
    set_homepage("https://sourceforge.net/projects/libsquish/")
    set_description("The libSquish library compresses images with the DXT standard (also known as S3TC).")
    set_license("MIT")

    add_urls("https://sourceforge.net/projects/libsquish/files/libsquish-$(version).tgz")
    add_versions("1.15", "628796eeba608866183a61d080d46967c9dda6723bc0a3ec52324c85d2147269")

    add_configs("openmp", {description = "Build with OpenMP.", default = false, type = "boolean"})
    add_configs("sse2", {description = "Build with SSE2.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
            package:add("defines", "SQUISH_USE_OPENMP")
        end

        if package:config("sse2") then
            package:add("defines", "SQUISH_USE_SSE=2")
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {
            openmp = package:config("openmp"),
            sse2 = package:config("sse2")
        })
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
