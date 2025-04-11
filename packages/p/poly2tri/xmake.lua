package("poly2tri")
    set_homepage("https://github.com/jhasse/poly2tri")
    set_description("2D constrained Delaunay triangulation library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/jhasse/poly2tri.git")
    add_versions("2024.02.08", "13d64e75a84dd8f36673a7eaf022e8e9fdd1f88b")

    add_deps("cmake")

    on_install(function (package)
        if package:config("shared") then
            io.replace("CMakeLists.txt", "if(poly2tri_target_type STREQUAL SHARED_LIBRARY)", "if(1)", {plain = true})
        else
            io.replace("poly2tri/common/dll_symbol.h", "define P2T_DLL_SYMBOL", "define P2T_DLL_SYMBOL P2T_COMPILER_DLLEXPORT", {plain = true})
            io.replace("CMakeLists.txt", "if(poly2tri_target_type STREQUAL SHARED_LIBRARY)", "if(0)", {plain = true})
        end
        io.replace("CMakeLists.txt", "add_library(poly2tri ${SOURCES} ${HEADERS})", [[
            add_library(poly2tri ${SOURCES} ${HEADERS})
            install(TARGETS ${PROJECT_NAME}
                RUNTIME DESTINATION bin
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib
            )
            install(DIRECTORY "${CMAKE_SOURCE_DIR}/poly2tri" DESTINATION include FILES_MATCHING PATTERN "*.h")
        ]], {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<p2t::Point*> polyline {
                    new p2t::Point(350, 500),
                    new p2t::Point(1050, 1700)
                };
                std::vector<p2t::Point*> hole {
                    new p2t::Point(591, 1350),
                    new p2t::Point(550, 2050)
                };
                p2t::CDT cdt{ polyline };
                cdt.AddHole(hole);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "poly2tri/poly2tri.h"}))
    end)
