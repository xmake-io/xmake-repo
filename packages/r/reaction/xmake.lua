package("reaction")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/lumia431/reaction")
    set_description("A lightweight, header-only reactive programming framework leveraging modern C++20 features for building efficient dataflow applications.")
    set_license("MIT")

    add_urls("https://github.com/lumia431/reaction.git")
    add_versions("2025.04.16", "424f1956f2215b0817fd1b3b4217ee04b0c45e2a")

    add_deps("cmake")

    on_check(function (package)
        if package:is_plat("android") then
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(reaction) require ndk version > 22")
        elseif package:is_plat("macosx") then
            assert(package:check_cxxsnippets({test = [[#include <format>
                    #include <iostream>

                    template<typename... Args>
                    inline void println(const std::format_string<Args...> fmt, Args&&... args)
                    {
                        std::cout << std::vformat(fmt.get(), std::make_format_args(args...)) << '\n';
                    }
                void test() {
                    println("{}{} {}{}", "Hello", ',', "C++", -1 + 2 * 3 * 4);
                }
            ]]}, {configs = {languages = "c++20"}}))
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "if(GTest_FOUND)", "if(0)", {plain = true})
        os.tryrm("example")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <algorithm>
            #include <reaction/reaction.h>
            void test() {
                auto buyPrice = reaction::var(100.0);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
