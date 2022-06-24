package("premake-core")
    set_homepage("https://premake.github.io/")
    set_description("Premake")

    add_urls("https://github.com/premake/premake-core.git")
    add_versions("2022.06.21", "1c22240cc86cc3a12075cc0fc8b07ab209f99dd3")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("premake-core")
               set_kind("$(kind)")
               add_files("src/*.c")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("premake5 --version")
    end)
