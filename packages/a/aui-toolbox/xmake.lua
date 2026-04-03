package("aui-toolbox")
    set_kind("binary")
    set_homepage("https://github.com/aui-framework/aui")
    set_description("Build tool for the AUI declarative UI toolkit")
    set_license("MPL-2.0")

    add_urls("https://github.com/aui-framework/aui/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aui-framework/aui.git")

    add_versions("v7.1.2", "a4cf965c50d75e20a319c9c8b231ad9c13c25a06ad303e1eb65d1ff141b1f85c")

    add_deps("aui", {configs = {
        components = {"core", "crypt", "image"}
    }})

    on_check(function (package)
        if package:is_cross() then
            raise("package(aui-toolbox): does not support cross-compilation.")
        end
    end)

    on_install("@windows", "@macosx", "@linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {})
    end)

    on_test(function (package)
        os.vrun("aui.toolbox")
    end)
