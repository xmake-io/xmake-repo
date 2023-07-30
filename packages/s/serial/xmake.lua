package("serial")
    set_homepage("http://wjwwood.github.io/serial")
    set_description("Cross-platform, Serial Port library written in C++")
    set_license("MIT")

    add_urls("https://github.com/wjwwood/serial.git")
    add_versions("2022.3.9", "69e0372cf0d3796e84ce9a09aff1d74496f68720")

    if is_plat("linux") then
        add_syslinks("rt", "pthread")
    elseif is_plat("windows") then
        add_syslinks("advapi32", "setupapi")
    end

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("serial")
                set_kind("$(kind)")
                add_files("src/serial.cc")
                add_includedirs("include")
                add_headerfiles("include/(serial/*.h)")
                if is_plat("windows") then
                    add_files("src/impl/win.cc")
                    add_files("src/impl/list_ports/list_ports_win.cc")
                    add_syslinks("advapi32", "setupapi")
                else
                    add_files("src/impl/unix.cc")
                    if is_plat("macosx") then
                        add_files("src/impl/list_ports/list_ports_osx.cc")
                    else
                        add_files("src/impl/list_ports/list_ports_linux.cc")
                        if is_plat("linux") then
                            add_syslinks("rt", "pthread")
                        end
                    end
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <serial/serial.h>
            void test() {
                serial::list_ports();
            }
        ]]}))
    end)
