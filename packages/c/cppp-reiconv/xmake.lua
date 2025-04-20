package("cppp-reiconv")
    set_homepage("https://github.com/cppp-project/cppp-reiconv")
    set_description("A character set conversion library based on GNU LIBICONV.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/cppp-project/cppp-reiconv/releases/download/$(version)/cppp-reiconv-$(version).zip",
             "https://github.com/cppp-project/cppp-reiconv.git")

    add_versions("v2.1.0", "3e539785a437843793c5ce2f8a72cb08f2b543cba11635b06db25cfc6d9cc3a4")

    add_patches("2.1.0", "patches/2.1.0/cmake.patch", "21bd2fcb5874f8774af1360aaac51073b67bf4c754096f0fe162d66632c1b7f9")

    add_deps("cmake", "python")

    on_install(function (package)
        local configs = {"-DENABLE_TEST=OFF", "-DENABLE_EXTRA=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cppp/reiconv.hpp>
            #include <iostream>
            #include <cstdlib>
            using namespace cppp::base::reiconv;

            void test()
            {
                iconv_t cd = iconv_open("UTF-8", "UTF-8");
                if (cd == (iconv_t)(-1))
                {
                    abort();
                }
                iconv_close(cd);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
