add_rules("mode.debug", "mode.release")
set_languages("c++14")

if not is_plat("windows", "mingw") then
    add_requires("egl-headers", "libpng", "libx11")
    add_packages("egl-headers", "libpng", "libx11")
end

target("gtgraphics")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Graphics/**.h)")
    add_files("GTE/Graphics/**.cpp")

    if is_plat("windows", "mingw") then
        add_syslinks("d3d11", "d3dcompiler", "dxguid", "dxgi", "windowscodecs")
        add_syslinks("opengl32", "user32", "ole32", "oleaut32", "gdi32")
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Graphics/GTGraphicsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Graphics/GL46/**.h")
        add_files("GTE/Graphics/DX11/**.cpp")
        remove_files("GTE/Graphics/GL46/**.cpp")
    else
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Graphics/DX11/**.h")
        add_files("GTE/Graphics/GL46/**.cpp")
        remove_files("GTE/Graphics/DX11/**.cpp")
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

    if is_plat("windows", "mingw") then
        add_syslinks("d3d11", "d3dcompiler", "dxguid", "dxgi", "windowscodecs")
        add_syslinks("opengl32", "user32", "ole32", "oleaut32", "gdi32")
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Applications/GTApplicationsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Applications/GLX/**.h")
        add_files("GTE/Applications/MSW/**.cpp")
        remove_files("GTE/Applications/GLX/**.cpp")
    else
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Applications/MSW/**.h")
        add_files("GTE/Applications/GLX/**.cpp")
        remove_files("GTE/Applications/MSW/**.cpp")
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

    if is_plat("windows", "mingw") then
        add_syslinks("d3d11", "d3dcompiler", "dxguid", "dxgi", "windowscodecs")
        add_syslinks("opengl32", "user32", "ole32", "oleaut32", "gdi32")
        add_defines("UNICODE", "_UNICODE", {public = true})
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        set_pcxxheader("GTE/MathematicsGPU/GTMathematicsGPUPCH.h")
    else
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtmathematics")
    add_rules("utils.install.cmake_importfiles")
    set_kind("headeronly")

    if is_plat("windows", "mingw") then
        add_defines("UNICODE", "_UNICODE", {public = true})
    end

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Mathematics/**.h)")
