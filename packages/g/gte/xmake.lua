package("gte")
    set_homepage("https://github.com/davideberly/GeometricTools")
    set_description("A collection of source code for computing in the fields of mathematics, geometry, graphics, image analysis and physics.")
    set_license("BSL-1.0")

    add_urls("https://github.com/davideberly/GeometricTools.git")
    add_versions("2025.08.20", "1ed0582d307b8608eb1b741d067f657e09483a5e")

    add_includedirs("include", "include/GTE")
    add_links("gtmathematicsgpu", "gtapplications", "gtgraphics")

    if is_plat("linux") then
        add_deps("egl-headers", "libpng", "libx11")
    end

    if is_plat("linux") then
        add_syslinks("GL", "GLX", "EGL", "X11")
    else
        add_syslinks("d3d11", "d3dcompiler", "dxguid", "dxgi", "windowscodecs")
        add_syslinks("opengl32", "user32", "ole32", "oleaut32", "gdi32")
    end

    on_install("windows", "linux", "mingw@!macosx", "msys", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        -- GCC15 requirement
        io.replace("GTE/Applications/Environment.h", "#include <cstdarg>", "#include <cstdarg>\n#include <cstdint>", {plain = true})
        if not is_plat("windows", "linux") then
            -- MinGW cant behave as MSVC 2015+ and define MSC_VER
            io.replace("GTE/Graphics/GTGraphics.cpp", "#if defined(GTE_USE_MSWINDOWS)", "#if 0", {plain = true})
            io.replace("GTE/Applications/GTApplications.cpp", "#if defined(GTE_USE_MSWINDOWS)", "#if 0", {plain = true})
            io.replace("GTE/Graphics/GL46/GTGraphicsGL46.cpp", "#if defined(GTE_USE_MSWINDOWS)", "#if 0", {plain = true})
            io.replace("GTE/Graphics/DX11/GTGraphicsDX11.cpp", "#if defined(GTE_USE_MSWINDOWS)", "#if 0", {plain = true})
            io.replace("GTE/MathematicsGPU/GTMathematicsGPU.cpp", "#if defined(GTE_USE_MSWINDOWS)", "#if 0", {plain = true})
            -- Supply missing DX11 implementation for MinGW
            os.cp(path.join(package:scriptdir(), "port", "d3d11-effects-mingw-supplements.h"), "GTE/Graphics/DX11/d3d11-effects-mingw-supplements.h")
            io.replace("GTE/Graphics/DX11/DX11.h", [[#if !defined(NOMINMAX)]], [[#include "d3d11-effects-mingw-supplements.h"
#if !defined(NOMINMAX)]], {plain = true})
        end
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memory>
            #include <GTE/MathematicsGPU/GTMathematicsGPU.h>
            void test() {
                std::shared_ptr<gte::GraphicsEngine> engine;
                std::shared_ptr<gte::ProgramFactory> factory;
                gte::GPUFluid2 fluid(engine, factory, 128, 128, 0.016f, 0.001f, 0.001f);
                fluid.Initialize();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
