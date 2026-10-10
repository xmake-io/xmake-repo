package("tiny-fmt")
    set_kind("library")
    set_homepage("https://github.com/monjaris/tiny-fmt")
    set_description("A modern lightweight formatting/logging library with {fmt} core")

     -- i update the project rapidly so i'd prefer auto follow git, if this works
    add_urls("https://github.com/monjaris/tiny-fmt.git")

    on_load(function (package)
        package:add("links", "tinyfmt")
        if package:config("shared") then
            package:add("defines", "TFMT_SHARED")
        end
    end)

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tinyfmt/tfmt.hpp>
            #include <string>
            static void test() {
                std::string s = tfmt::format("{}", 42);
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
