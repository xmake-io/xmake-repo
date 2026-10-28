package("tiny-fmt")
    set_kind("library")
    set_homepage("https://github.com/monjaris/tiny-fmt")
    set_description("A modern lightweight formatting/logging library with {fmt} core")
    set_license("MIT")

    add_urls("https://github.com/monjaris/tiny-fmt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/monjaris/tiny-fmt.git")
    add_versions("12.2.0-tiny-5", "634a2661ab518686a764657471a666c3d6e2a11dfe59861f014e95db0239e956")

    on_load(function (package)
        package:add("links", "tiny-fmt")
        if package:config("shared") then
            package:add("defines", "TFMT_SHARED")
        end
    end)

    on_install(function (package)
        local content, err = io.replace("include/tinyfmt/tfmt.hpp", "#  include <type_traits>  // std::enable_if",
                                        "#  include <cstddef>  // std::ptrdiff_t\n#  include <type_traits>  // std::enable_if", {plain = true})
        assert(content, err)

        if package:is_plat("windows") and package:config("shared") then
            content, err = io.replace("xmake.lua", 'add_defines("TFMT_SHARED")',
                                      'add_defines("TFMT_SHARED", "TFMT_LIB_EXPORT")', {plain = true})
            assert(content, err)
        end

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
