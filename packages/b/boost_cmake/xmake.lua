package("boost_cmake")
    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-cmake.tar.gz")
    add_versions("1.85.0", "ab9c9c4797384b0949dd676cf86b4f99553f8c148d767485aaac412af25183e6")

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("bzip2", "zlib")
        add_syslinks("pthread", "dl")
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/algorithm/string.hpp>
            #include <string>
            #include <vector>
            static void test() {
                std::string str("a,b");
                std::vector<std::string> vec;
                boost::algorithm::split(vec, str, boost::algorithm::is_any_of(","));
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
