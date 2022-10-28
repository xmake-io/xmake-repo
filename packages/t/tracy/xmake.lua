package("tracy")
    set_homepage("https://github.com/wolfpld/tracy")
    set_description("C++ frame profiler")

    add_urls("https://github.com/wolfpld/tracy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wolfpld/tracy.git")
    add_versions("v0.9", "93a91544e3d88f3bc4c405bad3dbc916ba951cdaadd5fcec1139af6fa56e6bfc")
    add_versions("v0.8.2", "4784eddd89c17a5fa030d408392992b3da3c503c872800e9d3746d985cfcc92a")

    add_deps("cmake")

    on_install("windows|x64", "macosx", "linux|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                FrameMarkStart("Test start");
                FrameMarkEnd("Test end");
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"tracy/Tracy.hpp"}}))
    end)
