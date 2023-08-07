package("lolly")
    set_homepage("https://github.com/XmacsLabs/lolly")
    set_description("Lolly is an alternative to the C++ Standard Library.")

    add_urls("https://github.com/XmacsLabs/lolly.git")
    add_urls("https://gitee.com/XmacsLabs/lolly.git")

    add_versions("v1.0.1", "69ebde6df3e5b4b9473f018d105f48f4abb179ff")

    if is_plat("mingw", "windows") then
        add_deps("nowide_standalone")
        add_configs("nowide_standalone", {description = "nowide", default = true, type = "boolean"})
    end

    on_load(function (package)
        if is_plat("mingw", "windows") then
            package:add("deps", "nowide_standalone")
        end
    end)

    on_install("linux", "macosx", "mingw", "wasm", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "string.hpp"
            void test() {
                string s("hello");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)

package_end()
