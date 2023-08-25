package("emmylua_debugger")
    set_kind("binary")
    set_homepage("https://github.com/EmmyLua/EmmyLuaDebugger")
    set_description("EmmyLua Debugger")

    add_urls("https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/$(version).tar.gz",
             "https://github.com/EmmyLua/EmmyLuaDebugger.git")

    add_versions("1.6.2", "80bfee98542a0ffe41459c5c77137e3628e931b5912a6b5e13f60b9ca67dd7c7")

    add_configs("luasrc", {description = "Use lua source.", default = true, type = "boolean"})
    add_configs("luaver", {description = "Set lua version.", default = "5.4.4", type = "string"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("luasrc") then
            local luaver = package:config("luaver")
            if luaver then
                package:add("deps", "lua " .. luaver)
            else
                package:add("deps", "lua")
            end
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
        import("core.base.semver")
        local configs = {}
        local cxflags
        if package:config("luasrc") then
            cxflags = "-DEMMY_USE_LUA_SOURCE=1"
            table.insert(configs, "-DEMMY_COMPILE_AS_LIB=ON")
        end
        local luaver = package:config("luaver")
        if luaver then
            local version = semver.new(luaver)
            table.insert(configs, "-DEMMY_LUA_VERSION=" .. version:major() .. version:minor())
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        io.replace("CMakeLists.txt", "set(CMAKE_INSTALL_PREFIX install)", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "lua", cxflags = cxflags})
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
