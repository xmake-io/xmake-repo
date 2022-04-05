package("ezc3d")

    set_homepage("https://github.com/pyomeca/ezc3d")
    set_description("Easy to use C3D reader/writer for C++, Python and Matlab")
    set_license("MIT")

    add_urls("https://github.com/pyomeca/ezc3d/archive/refs/tags/Release_$(version).tar.gz")
    add_versions("1.4.5", "01602b2ccfc0edd88089e89d249e10086022f7ed7ef40caa3eb3b048ccfa40aa")
    add_versions("1.4.7", "b11921ecd9ff5716f19b4a4eeede36f8cfa5ff08e6fd2c9c12e55f83e9d782bd")

    add_deps("cmake")
    add_includedirs("include/ezc3d")
    if not is_plat("windows") then
        add_linkdirs("lib/ezc3d")
    end
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_EXAMPLE=OFF", "-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            void test() {
                ezc3d::c3d c3d_empty;
                ezc3d::ParametersNS::GroupNS::Parameter t("SCALE");
                t.set(std::vector<double>(), {0});
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"ezc3d.h", "Parameters.h"}}))
    end)
