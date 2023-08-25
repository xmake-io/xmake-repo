package("emmylua_debugger")
    set_kind("binary")
    set_homepage("https://github.com/EmmyLua/EmmyLuaDebugger")
    set_description("EmmyLua Debugger")

    add_urls("https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/$(version).tar.gz",
             "https://github.com/EmmyLua/EmmyLuaDebugger.git")

    add_versions("1.6.2", "80bfee98542a0ffe41459c5c77137e3628e931b5912a6b5e13f60b9ca67dd7c7")
    add_versions("2023.08.25", "602402ffdd430cd9c2c86f1bff4d05688a07d785")

    add_configs("luasrc", {description = "Use lua source.", default = true, type = "boolean"})
    add_configs("luaver", {description = "Set lua version.", default = "5.4", type = "string"})

    add_deps("cmake")
    add_deps("lua 5.4.6")

    on_install("macosx", "linux", "windows", function (package)
        local configs = {}
        if package:config("luasrc") then
            table.insert(configs, "-DEMMY_USE_LUA_SOURCE=ON")
        end
        local luaver = package:config("luaver")
        if luaver then
            table.insert(configs, "-DEMMY_LUA_VERSION=" .. (luaver:gsub("%.", "")))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        io.replace("CMakeLists.txt", "set(CMAKE_INSTALL_PREFIX install)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local suffix
        if package:is_plat("macosx") then
            suffix = ".dylib"
        elseif package:is_plat("windows") then
            suffix = ".dll"
        else
            suffix = ".so"
        end
        assert(os.isfile(path.join(package:installdir("bin"), "emmy_core" .. suffix)))
    end)
