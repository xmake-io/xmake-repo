package("imguizmo")

    set_homepage("https://github.com/CedricGuillemet/ImGuizmo")
    set_description("Immediate mode 3D gizmo for scene editing and other controls based on Dear Imgui")

    add_urls("https://github.com/CedricGuillemet/ImGuizmo.git")

    add_versions("1.83", "14a91c16e40b585fd96314826fa6d506311dbe5c")

    add_deps("imgui")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
            local xmake_lua = [[
                add_rules("mode.debug", "mode.release")
                set_languages("c++14")
                
                add_requires("imgui v1.83-docking")

                target("imguizmo")
                    set_kind("static")
                    add_files("*.cpp")
                    add_headerfiles("*.h")
                    add_packages("imgui")
            ]]
            io.writefile("xmake.lua", xmake_lua)
            import("package.tools.xmake").install(package)
        end)
