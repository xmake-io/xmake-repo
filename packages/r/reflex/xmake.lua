package("reflex")
    set_description("The reflex package")

    add_urls("https://github.com/Genivia/RE-flex/archive/refs/tags/v$(version).tar.gz","https://github.com/Genivia/RE-flex.git")
    add_versions("3.5.1", "e08ed24a6799a6976f6e32312be1ee059b4b6b55f8af3b433a3016d63250c0e4")
    add_versions("4.3.0", "1658c1be9fa95bf948a657d75d2cef0df81b614bc6052284935774d4d8551d95")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            target("libreflex")
                set_kind("static")
                set_languages("cxx11")
                add_includedirs("include")
                add_files("lib/*.cpp")
                add_files("unicode/*.cpp")
            target_end()

            target("reflex")
                set_kind("binary")
                set_languages("cxx11")
                add_includedirs("include")
                add_files("src/*.cpp")
                add_deps("libreflex")
            target_end()
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        -- TODO check includes and interfaces
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"})
    end)