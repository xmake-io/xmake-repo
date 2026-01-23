package("pinocchio")
    set_homepage("http://stack-of-tasks.github.io/pinocchio/")
    set_description("A fast and flexible implementation of Rigid Body Dynamics algorithms and their analytical derivatives")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/stack-of-tasks/pinocchio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stack-of-tasks/pinocchio.git", {submodules = false})

    add_versions("v3.9.0", "721cf3e08956146856a9c9de914788bac4076536620bd7264722d6a7cfb50500")

    add_configs("urdf", {description = "Build the library with the URDF format support", default = false, type = "boolean"})
    add_configs("sdf", {description = "Build the library with the SDF format support", default = false, type = "boolean"})
    add_configs("collision", {description = "Build the library with the collision support (required HPP-FCL)", default = false, type = "boolean"})
    add_configs("autodiff", {description = "Build the library with the automatic differentiation support (via CppAD)", default = false, type = "boolean"})
    add_configs("casadi", {description = "Build the library with the support of CASADI", default = false, type = "boolean"})
    add_configs("openmp", {description = "Build the library with the OpenMP support", default = false, type = "boolean"})
    add_configs("extra", {description = "Build the library with extra algorithms support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("python", {description = "Build python interface", default = false, type = "boolean"})

    if is_plat("windows") then
        add_defines("WIN32", "NOMINMAX")
    end

    add_links("pinocchio_visualizers", "pinocchio_parsers", "pinocchio_default")

    add_deps("cmake", "jrl-cmakemodules")
    add_deps("eigen >=3.0.5")

    on_load(function (package)
        local boost_configs = {
            asio          = true,
            math          = true,
            graph         = true,
            filesystem    = true,
            serialization = true,
            thread        = true,
            iostreams     = true,
        }
        if package:config("python") then
            package:add("deps", "python 3.x")
            boost_configs.python = true
        end
        package:add("deps", "boost", {configs = boost_configs})

        local configdeps = {
            urdf      = "urdfdom",
            sdf       = "sdformat",
            collision = "coal",
            autodiff  = "cppad",
            casadi    = "casadi",
            openmp    = "openmp",
            extra     = "qhull",
        }
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end

        if not package:config("shared") then
            package:add("defines", "PINOCCHIO_STATIC")
        end
    end)

    -- failed to link
    on_install("!mingw", function (package)
        io.replace("CMakeLists.txt", "set_boost_default_options()", "", {plain = true})
        io.replace("CMakeLists.txt", "export_boost_default_options()", "", {plain = true})
        io.replace("src/CMakeLists.txt", "add_library(${LIB_NAME} ${LIBRARY_TYPE})", "add_library(${LIB_NAME})", {plain = true})
        if package:is_plat("mingw", "msys") then
            io.replace("include/pinocchio/macros.hpp",
                "#if WIN32\n  #define PINOCCHIO_PRETTY_FUNCTION __FUNCSIG__",
                "#if defined(_MSC_VER)\n  #define PINOCCHIO_PRETTY_FUNCTION __FUNCSIG__", {plain = true})
        end
        if package:config("urdf") then
            io.replace("CMakeLists.txt", "if(BUILD_WITH_URDF_SUPPORT)", [[if(BUILD_WITH_URDF_SUPPORT)
                    add_project_dependency(console_bridge REQUIRED)
                    add_project_dependency(tinyxml2 REQUIRED)
                ]], {plain = true})
        end

        local configs = {
            "-DBUILD_BENCHMARK=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_TESTING=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                local enabled_option = (enabled and "ON" or "OFF")
                if name == "tools" then
                    table.insert(configs, "-DBUILD_UTILS=" .. enabled_option)
                elseif name == "python" then
                    table.insert(configs, "-DBUILD_PYTHON_INTERFACE=" .. enabled_option)
                else
                    table.insert(configs, format("-DBUILD_WITH_%s_SUPPORT=%s", name:upper(), enabled_option))
                end
            end
        end

        local cxflags = {}
        if package:is_plat("windows") then
            -- workaround clang
            table.join2(cxflags, {"-DWIN32", "-DNOMINMAX"})
        end
        if package:has_tool("cxx", "cl") then
            table.insert(cxflags, "/bigobj")
        elseif package:has_tool("cxx", "gcc", "gxx") then
            table.insert(cxflags, "-Wa,-mbig-obj")
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        local cxflags
        if package:has_tool("cxx", "cl") then
            cxflags = {"/bigobj"}
        elseif package:has_tool("cxx", "gcc", "gxx") then
            cxflags = {"-Wa,-mbig-obj"}
        end
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
 
            #include <pinocchio/multibody/sample-models.hpp>
            #include <pinocchio/algorithm/joint-configuration.hpp>
            #include <pinocchio/algorithm/rnea.hpp>

            void test() {
                pinocchio::Model model;
                pinocchio::buildModels::manipulator(model);
                pinocchio::Data data(model);
                
                Eigen::VectorXd q = pinocchio::neutral(model);
                Eigen::VectorXd v = Eigen::VectorXd::Zero(model.nv);
                Eigen::VectorXd a = Eigen::VectorXd::Zero(model.nv);
                
                const Eigen::VectorXd & tau = pinocchio::rnea(model, data, q, v, a);
                std::cout << "tau = " << tau.transpose() << std::endl;
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}}))
    end)
