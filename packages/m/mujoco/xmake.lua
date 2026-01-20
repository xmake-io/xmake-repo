package("mujoco")
    set_homepage("https://mujoco.org/")
    set_description("Multi-Joint dynamics with Contact. A general purpose physics simulator.")
    set_license("Apache-2.0")

    set_urls("https://github.com/google-deepmind/mujoco/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google-deepmind/mujoco.git")

    add_versions("3.4.0", "adff5e9397aac20189ee1525aabf1fbecc63c43697e8ad66a61220222983810f")

    add_configs("simulate", {description = "Build simulate library for MuJoCo", default = false, type = "boolean"})
    add_configs("usd", {description = "Build with OpenUSD", default = false, type = "boolean"})

    add_links("simulate", "mujoco")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("libccd", "lodepng", "qhull", "tinyobjloader", "tinyxml2", "trianglemeshdistance", "marchingcubecpp")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(mujoco) require ndk api level > 21")
        end)
    end

    on_load(function (package)
        if package:config("usd") then
            package:add("deps", "usd")
            package:add("defines", "mjUSEUSD")
        end
        if package:config("simulate") then
            package:add("deps", "glfw")
        end

        if not package:config("shared") then
            package:add("defines", "MJ_STATIC")
        end
    end)

    on_install("!wasm and !bsd", function (package)
        if package:dep("qhull"):config("shared") then
            -- TODO: patch cmake target_link_libraries
            raise("package(mujoco) unsupported shared qhull library")
        end

        -- support static build
        io.replace("CMakeLists.txt", "add_library(mujoco SHARED", "add_library(mujoco ", {plain = true})
        -- remove fetch content
        io.replace("CMakeLists.txt", "include(MujocoDependencies)", "", {plain = true})
        -- remove hardcode ccd and dynamic library export macro
        io.replace("CMakeLists.txt", "CCD_STATIC_DEFINE MUJOCO_DLL_EXPORTS", "", {plain = true})
        -- remove unused install target
        io.replace("CMakeLists.txt", "list(APPEND MUJOCO_TARGETS lodepng)", "", {plain = true})
        if package:is_plat("mingw") then
            -- mujoco.rc:23: syntax error
            io.replace("CMakeLists.txt", "set(MUJOCO_RESOURCE_FILES ${CMAKE_CURRENT_SOURCE_DIR}/dist/mujoco.rc)", "", {plain = true})
            -- remove /STACK:16777216
            io.replace("cmake/MujocoLinkOptions.cmake", "if(WIN32)", "if(0)", {plain = true})
            io.replace("simulate/cmake/MujocoLinkOptions.cmake", "if(WIN32)", "if(0)", {plain = true})
        end

        io.replace("cmake/MujocoOptions.cmake", "set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)", "", {plain = true})
        io.replace("simulate/cmake/SimulateOptions.cmake", "set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)", "", {plain = true})

        io.replace("cmake/MujocoOptions.cmake", "-Werror", "", {plain = true})
        io.replace("simulate/cmake/SimulateOptions.cmake", "-Werror", "", {plain = true})

        io.replace("src/user/user_mesh.cc", [[#include "qhull_ra.h"]], "#include <libqhull_r/qhull_ra.h>", {plain = true})
        io.replace("src/user/user_mesh.cc",
            "#include <TriangleMeshDistance/include/tmd/TriangleMeshDistance.h>",
            "#include <tmd/TriangleMeshDistance.h>", {plain = true})

        io.replace("CMakeLists.txt", [[target_link_libraries(
  mujoco
  PRIVATE ccd
          lodepng
          qhullstatic_r
          tinyobjloader
          tinyxml2
)]], "", {plain = true})

        local file = io.open("CMakeLists.txt", "a")
        if file then
            file:print([[
                if (BUILD_SHARED_LIBS)
                    target_compile_definitions(mujoco PRIVATE MUJOCO_DLL_EXPORTS)
                else()
                    target_compile_definitions(mujoco PUBLIC MJ_STATIC)
                endif()
                
                find_package(ccd CONFIG REQUIRED)
                include(FindPkgConfig)
                pkg_search_module("lodepng" REQUIRED IMPORTED_TARGET "lodepng")
                find_package(Qhull CONFIG REQUIRED)
                find_package(tinyobjloader CONFIG REQUIRED)
                find_package(tinyxml2 CONFIG REQUIRED)
                pkg_search_module("trianglemeshdistance" REQUIRED IMPORTED_TARGET "trianglemeshdistance")
                pkg_search_module("marchingcubecpp" REQUIRED IMPORTED_TARGET "marchingcubecpp")
                target_link_libraries(mujoco PRIVATE
                    ccd
                    PkgConfig::lodepng
                    Qhull::qhullstatic_r
                    tinyobjloader::tinyobjloader
                    tinyxml2::tinyxml2
                    PkgConfig::trianglemeshdistance
                    PkgConfig::marchingcubecpp
                )
            ]])
            file:close()
        end

        if package:config("simulate") then
        -- remove fetch content
            io.replace("simulate/CMakeLists.txt", "include(SimulateDependencies)", "", {plain = true})
            io.replace("simulate/CMakeLists.txt", "if(NOT TARGET lodepng)", "if(0)", {plain = true})
            io.replace("simulate/CMakeLists.txt",
                "add_library(libmujoco_simulate STATIC $<TARGET_OBJECTS:platform_ui_adapter> $<TARGET_OBJECTS:lodepng>)",
                [[
                    add_library(libmujoco_simulate STATIC $<TARGET_OBJECTS:platform_ui_adapter>)
                    include(FindPkgConfig)
                    pkg_search_module("lodepng" REQUIRED IMPORTED_TARGET "lodepng")
                    find_package(Qhull CONFIG REQUIRED)
                    find_package(glfw3 REQUIRED CONFIG)
                    target_link_libraries(libmujoco_simulate PRIVATE PkgConfig::lodepng Qhull::qhullstatic_r)
                ]], {plain = true})
        end

        local configs = {
            "-DMUJOCO_BUILD_EXAMPLES=OFF",
            "-DMUJOCO_BUILD_TESTS=OFF",
            "-DMUJOCO_BUILD_TESTS_WASM=OFF",
            "-DMUJOCO_SIMULATE_USE_SYSTEM_GLFW=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DMUJOCO_BUILD_SIMULATE=" .. (package:config("simulate") and "ON" or "OFF"))
        table.insert(configs, "-DMUJOCO_WITH_USD=" .. (package:config("usd") and "ON" or "OFF"))

        local opt = {}
        opt.cxflags = {}
        if package:has_tool("cc", "gcc") or package:is_plat("wasm") then
            table.insert(opt.cxflags, "-Wno-error=incompatible-pointer-types")
        end
        if package:is_plat("android", "bsd", "mingw") then
            -- src/engine/engine_util_errmem.c:107:6: error: #error "Thread-safe version of `localtime` is not present in the standard C library"
            table.insert(opt.cxflags, "-D_POSIX_C_SOURCE=200112L")
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mjv_defaultCamera", {includes = "mujoco/mujoco.h"}))
    end)
