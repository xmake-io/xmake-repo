package("luabridge3")
    set_kind("library", {headeronly = true})
    set_homepage("https://kunitoki.github.io/LuaBridge3")
    set_description("LuaBridge3 is a lightweight and dependency-free library for mapping data, functions, and classes back and forth between C++ and Lua.")
    set_license("MIT")

    add_urls("https://github.com/kunitoki/LuaBridge3/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kunitoki/LuaBridge3.git")

    add_versions("3.0-rc4", "7aaebb588a8271993de58e45c5b126af96f7779a12fea0dee2a115de4de1d75b")
    add_versions("3.0-rc3", "842a3803587c42568f6f4e65314f762fb7724c9c7c91efc930282921dbf9a79f")
    
    on_install(function (package)
        os.cp("Source/LuaBridge", path.join(package:installdir("include"), "LuaBridge"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define LUA_VERSION_NUM
            #include <LuaBridge/detail/Errors.h>
            void test()
            {
                luabridge::ErrorCode errorCode;
                const luabridge::detail::ErrorCategory& category = luabridge::detail::ErrorCategory::getInstance();
                category.name();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)



