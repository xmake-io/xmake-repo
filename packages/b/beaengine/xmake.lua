package("beaengine")
    set_homepage("https://github.com/BeaEngine/beaengine")
    set_description("BeaEngine disasm project")
    set_license("LGPL-3.0-or-later")

    add_urls("https://github.com/BeaEngine/beaengine/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BeaEngine/beaengine.git")

    add_versions("v5.3.0", "a46712cb9ef6430ea7ba879bd9c70537680ef025f5382c541c62311686bc325d")

    add_configs("stdcall", {description = "Build using stdcall", default = true, type = "boolean"})
    add_configs("lite", {description = "Build without text disassembly", default = false, type = "boolean"})

    add_deps("zlib")

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "BEA_ENGINE_STATIC")
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {
            stdcall = package:config("stdcall"),
            lite = package:config("lite")
        })
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                const char* ver = BeaEngineVersion();
            }
        ]]}, {configs = {languages = "c99"}, includes = "beaengine/BeaEngine.h"}))
    end)
