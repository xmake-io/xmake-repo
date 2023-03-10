package("sphinxsys")

    set_homepage("https://www.sphinxsys.org")
    set_description("SPHinXsys (pronunciation: s'finksis) is an acronym from Smoothed Particle Hydrodynamics for industrial compleX systems.")

    set_urls("https://github.com/Xiangyu-Hu/SPHinXsys/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/Xiangyu-Hu/SPHinXsys.git")
    add_versions("1.0-beta.0.7", "5a3fbc2bc59795eae7c7721b41cf91d65924f81f66503585f63b4ada77aef96b")

    add_configs("SPHINXSYS_2D", {description = "Build sphinxsys_2d library.", default = true, type = "boolean"})
    add_configs("SPHINXSYS_3D", {description = "Build sphinxsys_2d library.", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {program_options = true}})
    add_deps("tbb")
    add_deps("simbody >=3.6.0")
    add_deps("eigen >=3.4")
    -- We can specify jobs to avoid potential memory overflow on windows.
    add_deps("ninja")

    on_install("windows", "linux", "macosx", function (package)
        -- We need copy source codes to the working directory with short path on windows
        --
        -- Because the target name and source file path of this project are too long,
        -- it's absolute path exceeds the windows path length limit.
        --
        local oldir
        if is_host("windows") then
            local sourcedir = os.tmpdir() .. ".dir"
            os.tryrm(sourcedir)
            if os.isfile("CMakeLists.txt") then
                os.cp(os.curdir(), sourcedir)
            else
                os.cp("SPHinXsys-" .. package:version(), sourcedir)
            end
            oldir = os.cd(sourcedir)
        end

        local configs = {"-DSPHINXSYS_BUILD_TESTS=OFF"}
        if not package:config("SPHINXSYS_2D") then
            table.insert(configs, "-DSPHINXSYS_2D=OFF")
        elseif not package:config("SPHINXSYS_3D") then
            table.insert(configs, "-DSPHINXSYS_3D=OFF")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs, {cmake_generator = "Ninja"})
        if oldir then
            os.cd(oldir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "sphinxsys.h"
            using namespace SPH;

            Real DL = 5.366;
            Real DH = 5.366;
            Real LL = 2.0;
            Real LH = 1.0;
            Real particle_spacing_ref = 0.025;
            Real BW = particle_spacing_ref * 4;
            BoundingBox system_domain_bounds(Vec2d(-BW, -BW), Vec2d(DL + BW, DH + BW));

            void test(int argc, char** argv) {
                SPHSystem sph_system(system_domain_bounds, particle_spacing_ref);
                sph_system.handleCommandlineOptions(ac, av);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
