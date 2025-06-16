package("openmvg")
    set_homepage("https://github.com/openMVG/openMVG")
    set_description("open Multiple View Geometry library. Basis for 3D computer vision and Structure from Motion.")
    set_license("MPL-2.0")

    add_urls("https://github.com/openMVG/openMVG.git")
    add_versions("2.1", "01193a245ee3c36458e650b1cf4402caad8983ef")

    add_configs("openmp", {description = "Enable OpenMP parallelization", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "eigen")

    if on_check then
        on_check("linux", function (package)
            assert(not package:has_tool("cxx", "clang"), "Linux Clang is not supported.")
        end)
    end

    on_load("linux", "windows", "macosx", function (package)
        if package:config("openmp") then package:add("deps", "openmp") end
    end)

    on_install("linux", "windows|x86", "windows|x64", "macosx", function (package)
        if is_plat("windows") then
            io.replace("src/openMVG/matching/metric_hamming.hpp", "#ifdef _MSC_VER",
                       "#if defined(_MSC_VER) && (defined(_M_X64) || defined(_M_IX86) || defined(_M_ARM64) || defined(_M_ARM64EC))", {plain = true})
        end
        os.cd("src")
        local configs = {
            "-DOpenMVG_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            "-DOpenMVG_BUILD_COVERAGE=OFF",
            "-DOpenMVG_BUILD_TESTS=OFF",
            "-DOpenMVG_BUILD_DOC=OFF",
            "-DOpenMVG_BUILD_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_SOFTWARES=OFF",
            "-DOpenMVG_BUILD_GUI_SOFTWARES=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)
