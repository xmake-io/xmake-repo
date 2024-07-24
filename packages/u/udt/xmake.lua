package("udt")
    set_homepage("https://github.com/dorkbox/UDT")
    set_description("UDP-based Data Transfer Protocol")
    set_license("Apache-2.0")

    set_urls("https://github.com/dorkbox/UDT.git")

    on_install(function (package)
        if is_plat("windows") then
            package:add("defines", "WINDOWS")
            package:add("links", "Ws2_32")
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("udt")
                set_kind("$(kind)")
                if is_mode("debug") then
                    add_defines("_DEBUG")
                end
                set_warnings("all")
                set_languages("cxx11")
                if is_plat("windows") then
                    add_defines("WINDOWS")
                    add_links(
                        "Ws2_32"
                    )
                else
                    add_links(
                        "pthread",
                        "m"
                    )
                end
                add_files("src/*.cpp")
                add_headerfiles("src/udt.h")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                UDT::startup();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "udt.h"}))
    end)
