package("gzip-hpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/gzip-hpp")
    set_description("Gzip header-only C++ library")
    set_license("MIT")

    add_urls("https://github.com/mapbox/gzip-hpp/archive/$(version).tar.gz",
             "https://github.com/mapbox/gzip-hpp.git")

    add_versions("v0.1.0", "7ce3908cd13f186987820be97083fc5e62a7c6df0877af44b334a92e868eff06")

    add_deps("zlib")
   
    on_install(function (package)
        io.replace("include/gzip/utils.hpp", "#include <cstdlib>", "#include <cstdlib>\n#include <stdint.h>", {plain = true})
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <gzip/compress.hpp>
            #include <gzip/decompress.hpp>
            #include <gzip/utils.hpp>
            #include <cassert>
            
            void test() {
                const std::string data("Hello World");
                for (int level = Z_BEST_SPEED; level <= Z_BEST_COMPRESSION; ++level)
                {
                    std::string compressed_data = gzip::compress(data.data(), data.size());
                    assert(gzip::is_compressed(compressed_data.data(), compressed_data.size()));
                    std::string new_data = gzip::decompress(compressed_data.data(), compressed_data.size());
                    assert(data == new_data);
                }
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)