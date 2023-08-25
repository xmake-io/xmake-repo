package("emmylua_debugger")
    set_kind("binary")
    set_homepage("https://github.com/EmmyLua/EmmyLuaDebugger")
    set_description("EmmyLua Debugger")

    add_urls("https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/$(version).tar.gz",
             "https://github.com/EmmyLua/EmmyLuaDebugger.git")

    add_versions("1.6.2", "80bfee98542a0ffe41459c5c77137e3628e931b5912a6b5e13f60b9ca67dd7c7")
    add_versions("2023.08.25", "2b2485d2a4bf6fce80aa05d7f93cf1bfad58a1e8")

    add_configs("luasrc", {description = "Use lua source.", default = true, type = "boolean"})
    add_configs("luaver", {description = "Set lua version.", default = "5.4", type = "string"})

    add_deps("cmake")

    on_load(function (package)
        local suffix
        if package:is_plat("macosx") then
            suffix = ".dylib"
        elseif package:is_plat("windows") then
            suffix = ".dll"
        else
            suffix = ".so"
        end
        package:addenv("EMMYLUA_DEBUGGER", "bin/emmy_core" .. suffix)
        package:mark_as_pathenv("EMMYLUA_DEBUGGER")
    end)

    on_install("macosx", "linux", "windows", function (package)
        import("core.base.semver")
        local configs = {}
        if package:config("luasrc") then
            table.insert(configs, "-DEMMY_USE_LUA_SOURCE=ON")
        end
        local luaver = package:config("luaver")
        if luaver then
            local version = semver.new(luaver)
            table.insert(configs, "-DEMMY_LUA_VERSION=" .. version:major() .. version:minor())
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        io.replace("CMakeLists.txt", "set(CMAKE_INSTALL_PREFIX install)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(os.isfile(os.getenv("EMMYLUA_DEBUGGER")))
    end)
