package("corrade")
    set_homepage("https://magnum.graphics/corrade/")
    set_description("Corrade is a multiplatform utility library written in C++11/C++14.")
    set_license("MIT")

    add_urls("https://github.com/mosra/corrade/archive/refs/tags/$(version).zip", {
        excludes = {"**/TestSuite/**", "**/Test/**"}})
    add_urls("https://github.com/mosra/corrade.git")
    add_versions("v2020.06", "d89a06128c334920d91fecf23cc1df48fd6be26543dc0ed81b2f819a92d70e72")

    add_patches("2020.06", "patches/2020.06/msvc.patch", "af90c9bad846a2cbe834fe270860446f6329636f9b9b7ad23454cf479c1dc05f")

    if is_plat("windows") then
        add_syslinks("shell32")
    elseif is_plat("linux") then
        add_syslinks("dl")
    end
    add_deps("cmake")
    on_load("windows", "linux", "macosx", function (package)
        if package:is_cross() then
            package:add("deps", "corrade", {host = true, private = true})
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("src/Corrade/Utility/StlForwardTuple.h", "__tuple", "tuple")
        io.replace("src/Corrade/Utility/Directory.h", "#include <initializer_list>",
            "#include <initializer_list>\n#include <vector>\n", {plain = true})
        io.replace("src/Corrade/Utility/Resource.h", "#include <utility>",
            "#include <utility>\n#include <vector>\n", {plain = true})
        io.replace("src/Corrade/Utility/Arguments.h", "#include <utility>",
            "#include <utility>\n#include <vector>\n", {plain = true})

        local configs = {
            "-DBUILD_TESTS=OFF",
            "-DWITH_TESTSUITE=OFF",
            "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DCORRADE_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
        if package:is_cross() then
            os.rm(path.join(package:installdir("bin"), "*"))
        else
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("corrade-rc --help")
        end
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            void test() {
                Corrade::Utility::Resource rs{"data"};
                rs.get(std::string("license.txt"));
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Corrade/Utility/Resource.h"}))
    end)
