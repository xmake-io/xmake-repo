package("corrade")

    set_homepage("https://magnum.graphics/corrade/")
    set_description("Cor­rade is a mul­ti­plat­form util­i­ty li­brary writ­ten in C++11/C++14.")
    set_license("MIT")

    add_urls("https://github.com/mosra/corrade/archive/refs/tags/v2020.06.tar.gz",
             "https://github.com/mosra/corrade.git")
    add_versions("v2020.06", "2a62492ccc717422b72f2596a3e1a6a105b9574aa9467917f12d19ef3aab1341")

    if is_plat("windows") then
        add_syslinks("shell32")
    elseif is_plat("linux") then
        add_syslinks("dl")
    end
    add_deps("cmake")
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            void test() {
                Corrade::Utility::Resource rs{"data"};
                rs.get(std::string("license.txt"));
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Corrade/Utility/Resource.h"}))
    end)
