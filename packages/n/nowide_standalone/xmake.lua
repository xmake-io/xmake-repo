package("nowide_standalone")
    set_homepage("https://github.com/boostorg/nowide/tree/standalone")
    set_description("C++ implementation of the Python Numpy library")
    set_license("Boost Software License, Version 1.0")

    add_urls("https://github.com/boostorg/nowide/releases/download/v$(version)/nowide_standalone_v$(version).tar.gz",
             "https://github.com/boostorg/nowide/tree/standalone")

    add_versions("11.3.1", "eaec4d331e3961f5eeb10c46a11691d62047900a7a40765b0f23cdd3181e6ca6")
    add_versions("11.3.0", "153ac93173c8de9c08e7701e471fa750f84c27e51fe329570c5aa06016591f8c")
    add_versions("11.2.0", "1869d176a8af389e4f7416f42bdd15d6a5db3c6e4ae77269ecb071a232304e1d")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "NOWIDE_DYN_LINK")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DNOWIDE_WERROR=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nowide/args.hpp>
            int test(int argc, char **argv)
            {
                nowide::args _(argc, argv); // Must use an instance!
                return argc;
            }
        ]]}))
    end)
