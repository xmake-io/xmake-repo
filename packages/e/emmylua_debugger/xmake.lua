package("emmylua_debugger")
    set_kind("binary")
    set_homepage("https://github.com/EmmyLua/EmmyLuaDebugger")
    set_description("EmmyLua Debugger")

    add_urls("https://github.com/EmmyLua/EmmyLuaDebugger/archive/refs/tags/$(version).tar.gz",
             "https://github.com/EmmyLua/EmmyLuaDebugger.git")

    add_versions("1.8.7", "971684c7a344eedd3cc1a1c1faa52b6a8f3d2361acb2c39797dd7dc6e6453690")
    add_versions("1.8.6", "41e053856b4cf6641a22d43d64c78a25dfbbe8eaa4a8c90e87b20b76193f1af8")
    add_versions("1.8.5", "3262b90978ac3c4d825008e1658b03cb03db547d9bb05ff7f843b05c7092a668")
    add_versions("1.8.4", "e94590ae2ad6ad3ec6d238d6e5991b4d2a7f5942fc329f8f627e1d24315bdb88")
    add_versions("1.8.3", "a2803b4eec21400ca61691824e9e7689c1f14735470081a3ef0c5234aa4e590f")
    add_versions("1.8.2", "2ce5adbfad4055072d39302dccf794ec45800e84a5f3ba4784b373078a9dff8c")
    add_versions("1.8.1", "0dbbfefe798425323bd1f531463675460fce3418d73ef29b495e7369f8c76475")
    add_versions("1.8.0", "21e5ba1c82e4386cd8ad4f8c76511d70319b899b414d29ecdaba35649325d2ee")
    add_versions("1.7.1", "8757d372c146d9995b6e506d42f511422bcb1dc8bacbc3ea1a5868ebfb30015f")
    add_versions("1.6.3", "4e10cf1c729fc58f72880895e63618cb91d186ff3b55f270cdaa089a2f8b20bc")

    add_configs("luasrc", {description = "Use lua source.", default = true, type = "boolean"})
    add_configs("luaver", {description = "Set lua version.", default = "5.4", type = "string"})

    if is_plat("windows") then
        add_configs("emmy_tool", {description = "Build emmy_tool", default = false, type = "boolean"})
        add_configs("emmy_hook", {description = "Build emmy_hook", default = false, type = "boolean"})
    end

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
        if package:is_plat("windows") then
            if not (package:config("emmy_tool") or package:config("emmy_hook")) then
                io.replace("CMakeLists.txt", "add_subdirectory(shared)", "", {plain = true})
            end
            if not package:config("emmy_tool") then
                io.replace("CMakeLists.txt", "add_subdirectory(emmy_tool)", "", {plain = true})
            end
            if not package:config("emmy_hook") then
                io.replace("CMakeLists.txt", "add_subdirectory(emmy_hook)", "", {plain = true})
                io.replace("CMakeLists.txt", "add_subdirectory(third-party/EasyHook)", "", {plain = true})
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(os.isfile(os.getenv("EMMYLUA_DEBUGGER")))
    end)
