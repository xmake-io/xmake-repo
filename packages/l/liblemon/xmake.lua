package("liblemon")
    set_homepage("https://lemon.cs.elte.hu/trac/lemon")
    set_description("Library for Efficient Modeling and Optimization in Networks.")
    set_license("BSL-1.0")

    add_urls("http://lemon.cs.elte.hu/pub/sources/lemon-$(version).tar.gz")
    add_versions("1.3.1", "71b7c725f4c0b4a8ccb92eb87b208701586cf7a96156ebd821ca3ed855bad3c8")
    add_patches("1.3.1", "patches/1.3.1/cmake-add-runtime-install-destination.patch", "44f0bafd4b4ba088cd060beac8b9cdc512de0370a981965056aa916b0c1c5b62")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    on_install(function (package)
        -- Do not build tests
        io.replace("CMakeLists.txt", "IF(${CMAKE_SOURCE_DIR} STREQUAL ${PROJECT_SOURCE_DIR})", "IF(0)", {plain = true})
        -- Fix CMake 4.0 removed old cmake policy
        io.replace("CMakeLists.txt", "CMAKE_POLICY(SET CMP0048 OLD)", "CMAKE_POLICY(SET CMP0048 NEW)", {plain = true})
        io.replace("CMakeLists.txt", "PROJECT(${PROJECT_NAME})", "PROJECT(${PROJECT_NAME} VERSION " .. package:version() .. ")", {plain = true})
        local configs = {
            "-DLEMON_ENABLE_GLPK=OFF",
            "-DLEMON_ENABLE_ILOG=OFF",
            "-DLEMON_ENABLE_COIN=OFF",
            "-DLEMON_ENABLE_SOPLEX=OFF"
        }
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <lemon/list_graph.h>
            void test() {
                lemon::ListDigraph g;
                lemon::ListDigraph::Node u = g.addNode();
                lemon::ListDigraph::Node v = g.addNode();
                lemon::ListDigraph::Arc  a = g.addArc(u, v);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
