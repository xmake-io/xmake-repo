package("corrade")
    set_homepage("https://magnum.graphics/corrade/")
    set_description("Cor­rade is a mul­ti­plat­form util­i­ty li­brary writ­ten in C++11/C++14.")
    set_license("MIT")

    add_urls("https://github.com/mosra/corrade.git")
    add_versions("2022.3.17", "4f53744bc2344168973eb73d41d262004f76be54")

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
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("corrade-rc --help")
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            void test() {
                Corrade::Utility::Resource rs{"data"};
                rs.get(std::string("license.txt"));
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Corrade/Utility/Resource.h"}))
    end)
