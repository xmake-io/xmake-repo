package("debug_assert")
    set_kind("library", {headeronly = true})
    set_homepage("http://foonathan.net/blog/2016/09/16/assertions.html")
    set_description("Simple, flexible and modular assertion macro.")
    set_license("zlib")

    add_urls("https://github.com/foonathan/debug_assert.git")
    add_versions("2022.11.13", "7ea47091830eec9a9c6a338c8a29da70494692a5")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>

            struct module_a : 
            debug_assert::default_handler,          // it uses the default handler
            debug_assert::set_level<1> // and this level
            {
            };

            void module_a_func(void* ptr)
            {
            DEBUG_ASSERT(ptr, module_a{});                                  // minimal assertion
            DEBUG_ASSERT(2 + 2 == 4, module_a{}, debug_assert::level<2>{}); // assertion with level
            DEBUG_ASSERT(1 == 0, module_a{},
                    "this should be true"); // assertion with additional parameters, i.e. a message
            DEBUG_UNREACHABLE(module_a{});       // mark unreachable statements
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"debug_assert.hpp"}}))
    end)
