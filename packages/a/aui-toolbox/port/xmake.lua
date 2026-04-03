add_rules("mode.debug", "mode.release")

add_requires("aui")

target("aui.toolbox")
    set_kind("binary")
    set_languages("c++20")

    -- Mirror what aui_executable does: recurse src/, add src as private include
    add_files("aui.toolbox/src/**.cpp")
    add_files("aui.toolbox/src/**.c")
    if is_plat("macosx", "iphoneos") then
        add_files("aui.toolbox/src/**.mm")
    end
    add_includedirs("aui.toolbox/src")

    -- aui.toolbox links PRIVATE aui::core aui::crypt aui::image
    add_packages("aui", {components = {"core", "crypt", "image"}})
