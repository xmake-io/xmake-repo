add_rules("mode.debug", "mode.release")
set_languages("c++14")

target("gtgraphics")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Graphics/*.h)")
    add_files("GTE/Graphics/*.cpp")

    if is_plat("windows", "mingw") then
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Graphics/GTGraphicsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Graphics/GL46/*.h")
        add_files("GTE/Graphics/DX11/*.cpp")
    else
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Graphics/DX11/*.h")
        add_files("GTE/Graphics/GL46/*.cpp")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtapplications")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/Applications/**.h)")
    add_files("GTE/Applications/*.cpp")

    if is_plat("windows", "mingw") then
        add_defines("UNICODE", "_UNICODE", {public = true})
        set_pcxxheader("GTE/Applications/GTApplicationsPCH.h")
        add_defines("GTE_USE_MSWINDOWS", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_DIRECTX")
        remove_headerfiles("GTE/Graphics/GLX/*.h")
        add_files("GTE/Graphics/MSW/*.cpp")
    else
        add_defines("GTE_USE_LINUX", "GTE_USE_ROW_MAJOR", "GTE_USE_MAT_VEC", "GTE_USE_OPENGL", "GTE_DISABLE_PCH")
        remove_headerfiles("GTE/Graphics/MSW/*.h")
        add_files("GTE/Graphics/GLX/*.cpp")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("gtmathematicsgpu")
    add_rules("utils.install.cmake_importfiles")
    set_kind("$(kind)")

    add_includedirs("GTE", {public = true})
    add_headerfiles("(GTE/MathematicsGPU/*.h)")
    add_files("GTE/MathematicsGPU/*.cpp")

    if is_plat("windows", "mingw") then
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
    add_headerfiles("(GTE/Mathematics/*.h)")
