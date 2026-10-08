package("tiny-fmt")
    set_homepage("https://github.com/monjaris/tiny-fmt")
    set_description("A modern lightweight formatting/logging library with {fmt} core")
    set_license("MIT")

    add_urls("https://github.com/monjaris/tiny-fmt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/monjaris/tiny-fmt.git")

    add_versions("12.2.0-tiny-4", "d3327c3df53603c2e708cc54084fe18954f1ca7dc1c5e5d6d07f3f0d8da7b354")

    on_load(function (package)
        package:add("links", "tinyfmt")
        if package:config("shared") then
            package:add("defines", "TFMT_SHARED")
        end
    end)

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        -- Your project already has a correct xmake.lua, just use it
        import("package.tools.xmake").install(package, configs)
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
