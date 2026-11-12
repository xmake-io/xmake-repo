package("enchantum")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ZXShady/enchantum")
    set_description("Faster enum reflection for C++17 since I don't want to wait for C++26 reflection.")
    set_license("MIT")

    add_urls("https://github.com/ZXShady/enchantum/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ZXShady/enchantum.git")

    add_versions("0.5.0", "654d43f6a88f6555d3cad80e9ce3e72e1346be5617c678b4ef10a06a77d7d647")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            enum class Color { RED, GREEN, BLUE };
            static_assert(enchantum::to_string(Color::RED) == "RED");
        ]]}, {configs = {languages = "c++17"}, includes = "enchantum/enchantum.hpp"}))
    end)
