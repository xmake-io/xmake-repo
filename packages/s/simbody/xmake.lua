package("simbody")

    set_homepage("https://simtk.org/home/simbody")
    set_description("High-performance C++ multibody dynamics/physics library for simulating articulated biomechanical and mechanical systems like vehicles, robots, and the human skeleton.")
    set_license("Apache-2.0")

    add_urls("https://github.com/simbody/simbody/archive/refs/tags/Simbody-$(version).tar.gz")
    add_versions("3.7", "d371a92d440991400cb8e8e2473277a75307abb916e5aabc14194bea841b804a")

    add_patches("3.7", path.join(os.scriptdir(), "patches", "3.7", "msvc.patch"), "ac80c1bf9266d7d5e256a632ea1e2a00260dcc4cb68d2a23272fb309af61d2b7")

    add_configs("blas", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    add_deps("cmake")
    if not is_plat("windows") then
        add_includedirs("include/simbody")
    end
    if is_plat("linux") then
        add_syslinks("dl")
    end
    on_load("windows", "macosx", "linux", function (package)
        package:add("deps", package:config("blas"))
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "SimTK_USE_STATIC_LIBRARIES")
        end
        local suffix = package:config("shared") and "" or "_static"
        for _, lib in ipairs({"SimTKsimbody", "SimTKmath", "SimTKcommon"}) do
            package:add("links", lib .. suffix)
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "if(WIN32)\n    set(LAPACK", "if(FALSE)\n    set(LAPACK", {plain = true})
        if package:config("blas") == "openblas" then
            io.replace("CMakeLists.txt", "REALTIME_LIB rt", "REALTIME_LIB rt gfortran", {plain = true})
        end
        io.replace("Simbody/Visualizer/simbody-visualizer/CMakeLists.txt", "TEST_STATIC_TARGET})", "TEST_STATIC_TARGET})\nadd_definitions(-DSimTK_USE_STATIC_LIBRARIES)", {plain = true})
        if package:is_plat("windows") then
            io.replace("CMakeLists.txt", "/MD", "/" .. package:config("vs_runtime"), {plain = true})
        end
        local configs = {"-DINSTALL_DOCS=OFF", "-DBUILD_TESTING=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_DYNAMIC_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace SimTK;
            void test() {
                MultibodySystem system;
                SimbodyMatterSubsystem matter(system);
                GeneralForceSubsystem forces(system);
                Force::Gravity gravity(forces, matter, YAxis, 9.8);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "Simbody.h"}))
    end)
