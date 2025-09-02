package("gte")
    set_homepage("https://github.com/davideberly/GeometricTools")
    set_description("A collection of source code for computing in the fields of mathematics, geometry, graphics, image analysis and physics.")
    set_license("BSL-1.0")

    add_urls("https://github.com/davideberly/GeometricTools.git")
    add_versions("2025.08.20", "1ed0582d307b8608eb1b741d067f657e09483a5e")

    add_includedirs("include", "include/GTE")

    if not is_plat("windows", "mingw") then
        add_deps("khrplatform", "libpng")
    end

    on_install(function (package)
        io.replace("GTE/Applications/Environment.h", "#include <cstdarg>", "#include <cstdarg>\n#include <cstdint>", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <memory>
            #include <GTE/MathematicsGPU/GTMathematicsGPU.h>
            void test() {
                std::shared_ptr<gte::GraphicsEngine> engine;
                std::shared_ptr<gte::ProgramFactory> factory;

                int32_t xSize = 128;
                int32_t ySize = 128;
                float dt = 0.016f;
                float densityViscosity = 0.001f;
                float velocityViscosity = 0.001f;

                gte::GPUFluid2 fluid(engine, factory, xSize, ySize, dt, densityViscosity, velocityViscosity);
                fluid.Initialize();
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
