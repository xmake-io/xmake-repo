package("libmodbus")
    set_homepage("https://libmodbus.org")
    set_description("A Modbus library for Linux, Mac OS, FreeBSD and Windows")
    set_license("LGPL-2.1")

    add_urls("https://github.com/stephane/libmodbus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephane/libmodbus.git")
    add_versions("v3.1.11", "8a750452ef86a53de6cec6fbca67bd5be08d0a1e87278a422fbce3003fd42d99")
    add_versions("v3.1.10", "e93503749cd89fda4c8cf1ee6371a3a9cc1f0a921c165afbbc4fd96d4813fa1a")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libmodbus")
    elseif is_plat("linux") then
        add_extsources("pacman::libmodbus", "apt::libmodbus")
    elseif is_plat("macosx") then
        add_extsources("brew::libmodbus")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        if (not is_host("windows")) and (not is_subhost("msys", "cygwin")) then
            package:add("deps", "autoconf", "automake", "libtool")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "msys", "cross", function (package)
        if (not is_host("windows")) and (not is_subhost("msys", "cygwin")) then
            import("package.tools.autoconf").install(package, {"--disable-tests"})
            return
        end

        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("modbus")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/*.h", {prefixdir = "modbus"})

                add_syslinks("ws2_32")
                add_includedirs("src/win32")
                if is_plat("windows") then
                    add_files("src/win32/modbus.rc")
                    add_defines("HAVE_CONFIG_H", "_CRT_SECURE_NO_DEPRECATE=1", "_CRT_NONSTDC_NO_DEPRECATE=1")
                    if is_mode("debug") then
                        add_defines("W32DEBUG")
                    end
                    if is_kind("shared") then
                        add_defines("DLLBUILD")
                    end
                end

                before_build(function (target)
                    local old = os.cd("src/win32")
                    os.exec("cscript /nologo configure.js")
                    os.cd(old)
                end)
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        else
            if package:is_plat("windows") then
                io.replace("src/modbus.h", "#  define MODBUS_API __declspec(dllimport)", "#  define MODBUS_API", {plain = true})
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("modbus_new_tcp", {includes = "modbus/modbus.h"}))
    end)
