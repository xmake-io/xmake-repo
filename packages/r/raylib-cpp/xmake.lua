package("raylib-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/RobLoach/raylib-cpp")
    set_description("C++ Object Oriented Wrapper for raylib")
    set_license("zlib")

    add_urls("https://github.com/RobLoach/raylib-cpp/archive/refs/tags/$(version).tar.gz", 
        "https://github.com/RobLoach/raylib-cpp.git")
    add_versions("v5.0.1", "f865785fee2cb18da6ad6a9012a2993a73f2a2b1")

	add_deps("raylib 5.x")

    on_install(function (package)
        os.cp("include/*.hpp", package:installdir("include/raylib-cpp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <raylib-cpp/raylib-cpp.hpp>
            void test() {
                raylib::Color color(255, 0, 0, 255);
                return 0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
