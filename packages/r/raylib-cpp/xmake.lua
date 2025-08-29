package("raylib-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/RobLoach/raylib-cpp")
    set_description("C++ Object Oriented Wrapper for raylib")
    set_license("zlib")

    add_urls("https://github.com/RobLoach/raylib-cpp/archive/refs/tags/$(version).tar.gz", 
             "https://github.com/RobLoach/raylib-cpp.git")

    add_versions("v5.5.0", "bcb4a4e241a95376e8562aa77c29976ed0921235a9f5326822130a7bcf4860a5")
    add_versions("v5.0.2", "d3a718170882bc873c973a19a824d7fa4bfd9d0087b4778057231409a240920d")
    add_versions("v5.0.1", "6d10469019700fd5993db9a18bdd0ed025105b1bf7dd8916e353eef8bfac6355")

	add_deps("raylib 5.x")

    on_install("windows", "linux", "macosx", "mingw", "android", function (package)
        os.cp("include/*.hpp", package:installdir("include/raylib-cpp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                raylib::Color color(255, 0, 0, 255);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "raylib-cpp/raylib-cpp.hpp"}))
    end)
