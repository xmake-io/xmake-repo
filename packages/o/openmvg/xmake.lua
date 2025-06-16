package("openmvg")
    set_homepage("https://github.com/openMVG/openMVG")
    set_description("open Multiple View Geometry library. Basis for 3D computer vision and Structure from Motion.")
    set_license("MPL-2.0")

    add_urls("https://github.com/openMVG/openMVG.git")
    add_versions("2.1", "01193a245ee3c36458e650b1cf4402caad8983ef")

    add_configs("openmp", {description = "Enable OpenMP parallelization", default = true, type = "boolean"})

    add_deps("cmake", "eigen")

    on_load("linux", "windows", "macosx", function (package)
        if package:config("openmp") then package:add("deps", "openmp") end
    end)

    on_install("linux", "windows", "macosx", function (package)
        os.cd("src")
        local configs = {
            "-DOpenMVG_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            "-DOpenMVG_BUILD_COVERAGE=" .. (package:is_plat("linux") and "ON" or "OFF"),
            "-DOpenMVG_BUILD_TESTS=ON",
            "-DOpenMVG_BUILD_DOC=OFF",
            "-DOpenMVG_BUILD_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_SOFTWARES=OFF",
            "-DOpenMVG_BUILD_GUI_SOFTWARES=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)
