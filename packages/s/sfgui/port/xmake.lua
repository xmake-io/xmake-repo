add_rules("mode.debug", "mode.release")
set_languages("c++17")

if is_plat("mingw") then
    add_requires("sfml", {configs = {graphics = true, shared = true}})
else
    add_requires("sfml", {configs = {graphics = true}})
end

add_requires("opengl")

if is_plat("linux", "bsd", "cross") then
    add_requires("libx11")
end

option("font", {default = true})

target("sfgui")
    set_kind("$(kind)")

    if is_plat("windows") then
        add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
    end

    if is_plat("windows", "mingw") and is_kind("shared") then
        add_defines("SFGUI_EXPORTS")
    end

    if is_kind("static") then
        add_defines("SFGUI_STATIC")
    end

    add_packages("sfml", "opengl")

    if is_plat("linux", "bsd", "cross") then
        add_packages("libx11")
    end

    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Foundation")
    end

    add_files("src/**.cpp")

    if not has_config("font") then
        remove_files("src/SFGUI/DejaVuSansFont.cpp")
    else
        add_defines("SFGUI_INCLUDE_FONT")
    end

    add_includedirs("src", "include", "extlibs/libELL/include")
    add_headerfiles("include/(SFGUI/**.hpp)", "include/(SFGUI/**.inl)")
