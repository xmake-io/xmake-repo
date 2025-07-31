add_rules("mode.debug", "mode.release")
add_rules("utils.install.cmake_importfiles")
set_languages("c++20")

option("utfcpp", {default = false})

add_requires("imgui")
add_rules("mode.release", "mode.debug")

if has_config("utfcpp") then
    add_requires("utfcpp")
end

target("imguitextselect")
    set_kind("$(kind)")
    add_files("textselect.cpp")
    add_headerfiles("textselect.hpp")
    add_packages("imgui")

    if has_config("utfcpp") then
        add_packages("utfcpp")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
