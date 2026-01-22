package("ompl")
    set_homepage("https://ompl.kavrakilab.org/")
    set_description("The Open Motion Planning Library (OMPL)")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/ompl/ompl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ompl/ompl.git", {submodules = false})

    add_versions("1.7.0", "e2e2700dfb0b4c2d86e216736754dd1b316bd6a46cc8818e1ffcbce4a388aca9")

    add_configs("vamp", {description = "Build VAMP", default = false, type = "boolean", readonly = true})
    add_configs("python", {description = "Build Python bindings", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_includedirs("include", "include/ompl-1.7")

    if is_plat("windows", "mingw") then
        add_syslinks("psapi", "ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("eigen")
    add_deps("boost >=1.68", {configs = {
        math = true,
        graph = true,
        program_options = true,
        serialization = true,
        regex = true,
        thread = true,
    }})

    on_load(function (package)
        if package:config("python") then
            package:add("deps", "python 3.x")
            package:add("deps", "boost >=1.68", {configs = {
                math = true,
                graph = true,
                program_options = true,
                serialization = true,
                regex = true,
                thread = true,

                python = true,
            }})
        end
    end)

    on_install(function (package)
        io.replace("src/ompl/CMakeLists.txt", "add_library(ompl SHARED ${OMPL_SOURCE_CODE})", "add_library(ompl ${OMPL_SOURCE_CODE})", {plain = true})

        local configs = {
            "-DOMPL_VERSIONED_INSTALL=OFF",
            "-DOMPL_REGISTRATION=OFF",
            "-DOMPL_BUILD_TESTS=OFF",
            "-DOMPL_BUILD_DEMOS=OFF",
            "-DOMPL_BUILD_PYTESTS=OFF",
            "-DR_EXEC=R_EXEC-NOTFOUND",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOMPL_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DOMPL_BUILD_VAMP=" .. (package:config("vamp") and "ON" or "OFF"))
        table.insert(configs, "-DOMPL_BUILD_PYBINDINGS=" .. (package:config("python") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ompl/base/spaces/RealVectorStateSpace.h>
            #include <ompl/geometric/SimpleSetup.h>
            #include <ompl/geometric/planners/rrt/RRT.h>

            namespace ob = ompl::base;
            namespace og = ompl::geometric;

            bool isStateValid(const ob::State *state) {
                return true; 
            }

            void test() {
                auto space(std::make_shared<ob::RealVectorStateSpace>(2));

                ob::RealVectorBounds bounds(2);
                bounds.setLow(0);
                bounds.setHigh(1);
                space->setBounds(bounds);

                og::SimpleSetup ss(space);

                ss.setStateValidityChecker(isStateValid);

                ob::ScopedState<> start(space);
                start[0] = 0.1; start[1] = 0.1;

                ob::ScopedState<> goal(space);
                goal[0] = 0.9; goal[1] = 0.9;

                ss.setStartAndGoalStates(start, goal);

                ob::PlannerStatus solved = ss.solve(1.0);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
