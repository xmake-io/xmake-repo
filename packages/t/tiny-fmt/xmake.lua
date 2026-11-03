package("tiny-fmt")
    set_homepage("https://github.com/monjaris/tiny-fmt")
    set_description("A modern lightweight formatting/logging library with {fmt} core")
    set_license("MIT")

    add_urls("https://github.com/monjaris/tiny-fmt/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return tostring(version) .. "-tiny-5"
    end})
    add_urls("https://github.com/monjaris/tiny-fmt.git", {version = function (version)
        return tostring(version) .. "-tiny-5"
    end})

    add_versions("12.2.0", "634a2661ab518686a764657471a666c3d6e2a11dfe59861f014e95db0239e956")

    add_links("tiny-fmt")

    on_load(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/utf-8")
        end
        if package:config("shared") then
            package:add("defines", "TFMT_SHARED")
        end
    end)

    on_install(function (package)
        io.replace("include/tinyfmt/tfmt.hpp", "#  include <type_traits>  // std::enable_if",
                   "#  include <cstddef>  // std::ptrdiff_t\n#  include <type_traits>  // std::enable_if", {plain = true})
        io.replace("include/tinyfmt/tfmt.hpp", "#  include <iosfwd>  // std::string", "#  include <string>", {plain = true})
        if package:is_plat("windows", "mingw") and package:config("shared") then
            io.replace("xmake.lua", 'add_defines("TFMT_SHARED")', 'add_defines("TFMT_SHARED", "TFMT_LIB_EXPORT")', {plain = true})
        end

        import("package.tools.xmake").install(package, {}, {target = "tiny-fmt"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tinyfmt/tfmt.hpp>
            #include <string>
            static void test() {
                std::string s = tfmt::format("{}", 42);
            }
        ]]}, {configs = {languages = "c++23", cxflags = package:has_tool("cxx", "cl") and "/utf-8" or nil}}))
    end)
