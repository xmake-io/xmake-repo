package("magic_enum")
    set_kind("library", {headeronly = true})

    set_homepage("https://github.com/Neargye/magic_enum")
    set_description("Static reflection for enums (to string, from string, iteration) for modern C++, work with any enum type without any macro or boilerplate code")
    set_license("MIT")

    add_urls("https://github.com/Neargye/magic_enum/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Neargye/magic_enum.git")
    add_versions("v0.7.3", "b8d0cd848546fee136dc1fa4bb021a1e4dc8fe98e44d8c119faa3ef387636bf7")
    add_versions("v0.8.0", "5e7680e877dd4cf68d9d0c0e3c2a683b432a9ba84fc1993c4da3de70db894c3c")
    add_versions("v0.8.1", "6b948d1680f02542d651fc82154a9e136b341ce55c5bf300736b157e23f9df11")
    add_versions("v0.8.2", "62bd7034bbbfc3d7806001767d5775ab42f3ff33bb38366e1ceb21102f0dff9a")
    add_versions("v0.9.0", "2fb2f602b4660f8af539ee00958132a397e138bda19aa1ceae546de3a143386b")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DMAGIC_ENUM_OPT_BUILD_EXAMPLES=OFF",
            "-DMAGIC_ENUM_OPT_BUILD_TESTS=OFF",
            "-DMAGIC_ENUM_OPT_INSTALL=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            enum class Color { RED = 2, BLUE = 4, GREEN = 8 };
            void test() {
                Color color = Color::RED;
                auto color_name = magic_enum::enum_name(color);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "magic_enum.hpp"}))
    end)
