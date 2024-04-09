package("plf_stack")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/stack.htm")
    set_description("A data container replicating std::stack functionality but with better performance than standard library containers in a stack context.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_stack.git")
    -- v2.02 has an unfortunate compile error.
    add_versions("v2.01", "9d11bf2c5de5df739c0943af942a544c95b26ffa")

    on_install(function (package)
        os.cp("plf_stack.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <plf_stack.h>
            void test() {
                plf::stack<int> i_stack;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
