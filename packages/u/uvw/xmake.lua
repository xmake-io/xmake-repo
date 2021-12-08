package("uvw")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/skypjack/uvw")
    set_description("Header-only, event based, tiny and easy to use libuv wrapper in modern C++")

    add_urls("https://github.com/skypjack/uvw.git")

    add_versions("2.10.0", "v2.10.0_libuv_v1.42")

    add_deps("cmake", "libuv")

    on_install("macosx", "linux", "iphoneos", "android@linux,macosx", "mingw@linux,macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <uvw.hpp>
            void test() {
                auto loop = uvw::Loop::getDefault();
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end)
