package("imguizmo")

    set_homepage("https://github.com/CedricGuillemet/ImGuizmo")
    set_description("Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui")

    add_urls("https://github.com/CedricGuillemet/ImGuizmo/archive/$(version).tar.gz",
                 "https://github.com/CedricGuillemet/ImGuizmo.git")

    add_versions("1.83", "e6d05c5ebde802df7f6c342a06bc675bd2aa1c754d2d96755399a182187098a8")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
            local xmake_lua
            xmake_lua = [[
                add_rules("mode.debug", "mode.release")
                add_requires("imgui v1.83", {build = true})

                target("imguizmo")
                    set_kind("static")
                    add_files("*.cpp")
                    add_headerfiles("*.h")
                    add_packages("imgui")
            ]]
            io.writefile("xmake.lua", xmake_lua)
            import("package.tools.xmake").install(package)
        end)
