package("plf_stack")
    set_kind("library", {headeronly = true})
    set_homepage("https://plflib.org/stack.htm")
    set_description("A data container replicating std::stack functionality but with better performance than standard library containers in a stack context.")
    set_license("zlib")

    add_urls("https://github.com/mattreecebentley/plf_stack.git")
    add_versions("v2.03", "ec248e8eb98667ffc9cc1415f7750a774a2fc359")

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
