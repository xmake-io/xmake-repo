package("lolly")
    set_homepage("https://github.com/XmacsLabs/lolly")
    set_description("Lolly is a C++ library")

    add_urls("https://github.com/XmacsLabs/lolly.git")
    add_urls("https://gitee.com/XmacsLabs/lolly.git")

    add_versions("v1.0.1", "69ebde6df3e5b4b9473f018d105f48f4abb179ff")

    add_deps("nowide_standalone")
    if is_plat("mingw", "windows") then
        add_configs("nowide_standalone", {description = "nowide", default = true, type = "boolean"})
    end

    on_load(function (package)
        for _, dep in ipairs({"nowide_standalone"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("linux", "macosx", "mingw", "wasm", function (package)
        io.writefile("xmake.lua", [[
            option("nowide_standalone", {description = "nowide", default = false})
            add_rules("mode.debug", "mode.release")
            if has_config("nowide_standalone") then
                add_requires("nowide_standalone")
            end
            target("lolly")
                set_kind("static")
        ]])
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