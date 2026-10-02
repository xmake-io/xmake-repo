package("imguizmo")
    set_homepage("https://github.com/CedricGuillemet/ImGuizmo")
    set_description("Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui")
    set_license("MIT")

    add_urls("https://github.com/CedricGuillemet/ImGuizmo.git")

    add_versions("1.91.3+wip.0110", "b796ac3b861afc6e91ca74e4611effd9c9527367") -- v1.10
    add_versions("1.91.3+wip.0109", "9e437c6ce80453bd45a5674ac2d81ee754cee95c") -- v1.9
    add_versions("1.91.3+wip", "bcdd86bb8a8019b373e46921c52ef7f2fdaa8b16")
    add_versions("1.89+wip", "82e2465b8d029e2d85002905cc4ed5087e2119fe")
    add_versions("1.83", "664cf2d73864a36b2a8b5091d33fc4578c885eca") --v1.83

    on_load(function (package)
        -- Note: semver comparison ignores build metadata after '+' (1.91.3+wip equals 1.91.3+wip.0109),
        -- so use a version_str() string comparison to distinguish these commits
        if package:gitref() or package:version():ge("1.90") then
            if package:version_str() >= "1.91.3+wip.0109" then
                -- Since this commit ImGuizmo adapts to the imgui 1.92.8 ImDrawList argument swap
                package:add("deps", "imgui >=1.92.8")
            else
                package:add("deps", "imgui")
            end
        else
            package:add("deps", "imgui <=1.89.3")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        local imgui = package:dep("imgui")
        local configs = imgui:requireinfo().configs
        if configs then
            configs = string.serialize(configs, {strip = true, indent = false})
        end
        -- Since 2026-05 the library sources (including headers) moved from the repo root into src/;
        -- detect the actual layout. The "src/(*.h)" pattern strips the src/ prefix so headers
        -- are still installed into the include root.
        local srcdir = os.isfile("src/ImGuizmo.cpp") and "src/" or ""
        local headerfiles = srcdir == "" and "*.h" or (srcdir .. "(*.h)")
        local xmake_lua = ([[
            add_rules("mode.debug", "mode.release")
            set_languages("c++14")

            add_requires("imgui %s", {configs = %s})

            target("imguizmo")
                set_kind("$(kind)")
                add_defines("IMGUI_DEFINE_MATH_OPERATORS")
                add_files("%s*.cpp")
                add_headerfiles("%s")
                add_packages("imgui")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]]):format(imgui:version_str(), configs, srcdir, headerfiles)
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ImGuiIO& io = ImGui::GetIO();
                ImGuizmo::SetRect(0, 0, io.DisplaySize.x, io.DisplaySize.y);
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"imgui.h", "ImGuizmo.h"}}))
    end)
