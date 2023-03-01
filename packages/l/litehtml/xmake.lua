package("litehtml")
    set_homepage("http://www.litehtml.com/")
    set_description("Fast and lightweight HTML/CSS rendering engine")

    add_urls("https://github.com/litehtml/litehtml.git")
    add_versions("2023.01.05", "1e803393bdc8e586e8eefd4c33973e04994bb288")

    add_deps("cmake", "gumbo-parser")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DEXTERNAL_GUMBO=ON"}
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "gumbo-parser"})
        os.cp("include/litehtml.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            #include <litehtml.h>
            using namespace litehtml;
            void test() {
                css_element_selector selector;
                selector.parse(".class");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
