package("blitz")

    set_homepage("https://github.com/blitzpp/blitz")
    set_description("Blitz++ Multi-Dimensional Array Library for C++")
    set_license("LGPL-3.0")

    add_urls("https://github.com/blitzpp/blitz/archive/refs/tags/$(version).zip",
             "https://github.com/blitzpp/blitz.git")
    add_versions("1.0.2", "a477b9692a47363fce5929bba6d6d230773ddfbb020ce6841f7a961a55b9e71f")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("python 3.x", {kind = "binary"})

    on_install("windows", "macosx", "linux", function (package)
        io.replace("src/CMakeLists.txt", "SHARED", package:config("shared") and "SHARED" or "STATIC", {plain = true})
        io.replace("src/CMakeLists.txt", "NOT WIN32", "FALSE", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                blitz::Array<double, 1> x(100);
                x = blitz::tensor::i;
                blitz::Array<double, 1> y(x + 150);
                blitz::Array<double, 1> z(x + y * 2);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "blitz/array.h"}))
    end)
