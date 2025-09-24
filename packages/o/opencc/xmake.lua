package("opencc")
    set_homepage("https://github.com/BYVoid/OpenCC")
    set_description("Conversion between Traditional and Simplified Chinese.")
    set_license("Apache-2.0")

    add_urls("https://github.com/BYVoid/OpenCC/archive/refs/tags/ver.$(version).tar.gz")
    add_urls("https://github.com/BYVoid/OpenCC.git", {alias = "git"})

    add_versions("1.1.9", "ad4bcd8d87219a240a236d4a55c9decd2132a9436697d2882ead85c8939b0a99")
    
    add_versions("git:1.1.9", "ver.1.1.9")

    add_configs("darts", {description = "Build DartsDict (ocd format)", default = true, type = "boolean"})

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    end
    add_deps("marisa v0.2.6", "rapidjson", "tclap")

    on_load(function (package)
        if package:config("darts") then
            package:add("deps", "darts")
            package:add("defines", "ENABLE_DARTS")
        end
        if not package:config("shared") then
            package:add("defines", "Opencc_BUILT_AS_STATIC")
        end
    end)

    on_install(function (package)
        io.replace("src/CMakeLists.txt", "set_target_properties(libopencc PROPERTIES POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        io.replace("src/CMakeLists.txt", "target_link_libraries(libopencc marisa)", "", {plain = true})
        local file = io.open("src/CMakeLists.txt", "a")
        if file then
            file:write([[
                if (USE_SYSTEM_MARISA)
                    include(FindPkgConfig)
                    pkg_search_module(marisa REQUIRED IMPORTED_TARGET marisa)
                    target_link_libraries(libopencc PUBLIC PkgConfig::marisa)
                endif()
                if (USE_SYSTEM_RAPIDJSON)
                    find_package(RapidJSON CONFIG REQUIRED)
                    target_link_libraries(libopencc PUBLIC rapidjson)
                endif()
                if (USE_SYSTEM_TCLAP)
                    include(FindPkgConfig)
                    pkg_search_module(tclap REQUIRED IMPORTED_TARGET tclap)
                    target_link_libraries(libopencc PUBLIC PkgConfig::tclap)
                endif()
                if (USE_SYSTEM_DARTS)
                    include(FindPkgConfig)
                    pkg_search_module(darts REQUIRED IMPORTED_TARGET darts)
                    target_link_libraries(libopencc PUBLIC PkgConfig::darts)
                endif()
            ]])
            file:close()
        end

        local configs = {
            "-DBUILD_DOCUMENTATION=OFF",
            "-DENABLE_GTEST=OFF",
            "-DENABLE_BENCHMARK=OFF",
            "-DBUILD_PYTHON=OFF",
            "-DUSE_SYSTEM_DARTS=ON",
            "-DUSE_SYSTEM_RAPIDJSON=ON",
            "-DUSE_SYSTEM_TCLAP=ON",
            "-DUSE_SYSTEM_MARISA=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DARTS=" .. (package:config("darts") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opencc_open", {includes = "opencc/opencc.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                opencc::Config config;
            }
        ]]}, {includes = {"opencc/Config.hpp"}}))
    end)
