set_project("irrlicht")

option("tools", {default = false, showmenu = true})

add_rules("mode.debug", "mode.release")

add_requires("bzip2", "libjpeg-turbo", "libpng", "zlib")
if is_plat("linux") then
    add_requires("libx11", "libxxf86vm", "libxcursor", "libxext")
end
if has_config("tools") and is_plat("macosx", "linux") then
    add_requires("libxft")
end

target("Irrlicht")
    set_kind("$(kind)")
    add_files("source/Irrlicht/*.cpp")
    add_files("source/Irrlicht/lzma/*.c")
    add_files("source/Irrlicht/aesGladman/*.cpp")
    add_includedirs("source/Irrlicht")
    add_includedirs("include", {public = true})
    add_headerfiles("include/(**.h)")
    add_packages("bzip2", "libjpeg-turbo", "libpng", "zlib")
    add_defines(is_kind("shared") and "IRRLICHT_EXPORTS" or "_IRR_STATIC_LIB_", {public = is_kind("static")})
    add_defines("NO_IRR_USE_NON_SYSTEM_ZLIB_",
                "NO_IRR_USE_NON_SYSTEM_BZLIB_",
                "NO_IRR_USE_NON_SYSTEM_JPEG_LIB_",
                "NO_IRR_USE_NON_SYSTEM_LIB_PNG_")
    add_defines("NO_IRR_COMPILE_WITH_DIRECT3D_9_",
                "NO_IRR_COMPILE_WITH_BURNINGSVIDEO_")
    if is_plat("windows") then
        add_syslinks("user32", "gdi32", "advapi32")
    elseif is_plat("macosx") then
        add_frameworks("Cocoa", "OpenGL", "IOKit")
        add_files("source/Irrlicht/MacOSX/*.mm")
        add_cxxflags("-ObjC++")
        set_values("objc++.build.arc", false)
    elseif is_plat("linux") then
        add_syslinks("GL")
        add_packages("libx11", "libxxf86vm", "libxcursor", "libxext")
    end
target_end()

if has_config("tools") then
target("MeshConverter")
    set_kind("binary")
    add_deps("Irrlicht")
    add_files("tools/MeshConverter/*.cpp")
target_end()

target("IrrFontTool")
    set_kind("binary")
    add_deps("Irrlicht")
    add_files("tools/IrrFontTool/newFontTool/*.cpp")
    if is_plat("windows") then
        add_syslinks("gdi32")
    elseif is_plat("macosx", "linux") then
        add_packages("libxft")
    end
target_end()

target("GUIEditor")
    set_kind("binary")
    add_deps("Irrlicht")
    add_files("tools/GUIEditor/*.cpp")
target_end()

target("FileToHeader")
    set_kind("binary")
    add_deps("Irrlicht")
    add_files("tools/FileToHeader/*.cpp")
target_end()
end
