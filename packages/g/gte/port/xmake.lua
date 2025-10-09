add_rules("mode.debug", "mode.release")
set_languages("c++14")

if is_plat("linux") then
    add_requires("egl-headers", "libpng", "libx11")
    add_packages("egl-headers", "libpng", "libx11")
end

target("gtgraphics")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Graphics/**.h)")
    add_files("GTE/Graphics/**.cpp")

    if is_plat("linux") then
        add_syslinks("GL", "GLX", "EGL", "X11")
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Graphics/DX11/**.h")
        add_files("GTE/Graphics/GL46/**.cpp")
        remove_files("GTE/Graphics/DX11/**.cpp")
        remove_files("GTE/Graphics/GL46/WGL/**.cpp")
    else
        add_syslinks("d3d11", "d3dcompiler", "dxgi", "dxguid")
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Graphics/GTGraphicsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Graphics/GL46/**.h")
        add_files("GTE/Graphics/DX11/**.cpp")
        remove_files("GTE/Graphics/GL46/**.cpp")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtapplications")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_deps("gtgraphics", "gtmathematics")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Applications/**.h)")
    add_files("GTE/Applications/**.cpp")

    if is_plat("linux") then
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Applications/MSW/**.h")
        add_files("GTE/Applications/GLX/**.cpp")
        remove_files("GTE/Applications/MSW/**.cpp")
    else
        add_syslinks("windowscodecs", "ole32", "oleaut32", "gdi32", "user32")
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Applications/GTApplicationsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Applications/GLX/**.h")
        add_files("GTE/Applications/MSW/**.cpp")
        remove_files("GTE/Applications/GLX/**.cpp")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtmathematicsgpu")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_deps("gtgraphics", "gtmathematics", "gtapplications")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/MathematicsGPU/**.h)")
    add_files("GTE/MathematicsGPU/**.cpp")

    if is_plat("linux") then
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
    else
        add_defines("UNICODE", "_UNICODE", {public = true})
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        set_pcxxheader("GTE/MathematicsGPU/GTMathematicsGPUPCH.h")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtmathematics")
    add_rules("utils.install.cmake_importfiles")
    set_kind("headeronly")

    if not is_plat("linux") then
        add_defines("UNICODE", "_UNICODE", {public = true})
    end

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Mathematics/**.h)")
