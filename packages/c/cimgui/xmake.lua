package("cimgui")
    set_homepage("https://github.com/cimgui/cimgui")
    set_description("c-api for imgui (https://github.com/ocornut/imgui) Look at: https://github.com/cimgui for other widgets")
    set_license("MIT")

    add_urls("https://github.com/cimgui/cimgui.git")
    add_versions("2023.08.02", "a21e28e74027796d983f8c8d4a639a4e304251f2")

    add_configs("imgui", {description = "Use xmake-repo imgui", default = false, type = "boolean", readonly = true})
    add_configs("target", {description = "options as words in one string: internal for imgui_internal generation, freetype for freetype generation, comments for comments generation, nochar to skip char* function version, noimstrv to skip imstrv", default = "internal noimstrv", type = "string"})

    add_deps("luajit", {kind = "binary"})

    on_load(function (package)
        if package:config("imgui") then
            package:add("deps", "imgui")
        else
            if package:is_plat("windows") then
                package:add("syslinks", "imm32")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local envs = {}
        -- codegen script
        local args = {"generator.lua"}
        -- get compiler
        if package:is_plat("windows") then
            import("package.tools.msbuild")

            table.insert(args, "cl")
            table.join2(envs, msbuild.buildenvs(package))
        else
            if package:has_tool("cc", "gcc", "gxx") then
                table.insert(args, "gcc")
            elseif package:has_tool("cc", "clang", "clangxx") then
                table.insert(args, "clang")
            else
                raise("Compiler not found")
            end
        end

        table.insert(args, package:config("target"))
        -- add CFLAGS
        table.join2(args, table.wrap(package:config("cflags")))
        table.join2(args, table.wrap(package:config("cxflags")))
        for _, define in ipairs(table.wrap(package:config("defines"))) do
            table.insert(args, "-D" .. define)
        end

        if package:config("imgui") then
            envs.IMGUI_PATH = package:dep("imgui"):installdir("include")
        end
        -- codegen
        os.vrunv("luajit", args, {envs = envs, curdir = "generator"})

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("cimgui")
                set_kind("$(kind)")
                add_files("cimgui.cpp", "imgui/*.cpp")
                add_headerfiles("cimgui.h", "generator/output/cimgui_impl.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
            #include <cimgui.h>
            void test() {
                igCreateContext(NULL);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
