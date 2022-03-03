package("libfive")

    set_homepage("https://libfive.com/")
    set_description("libfive is a software library and set of tools for solid modeling, especially suited for parametric and procedural design.")

    add_urls("https://github.com/libfive/libfive.git")
    add_versions("2021.04.08", "e6a6448694f2204b003e29bba45754461261b9b2")
    add_versions("2022.02.22", "03b592cfc0fa3d9b3cf8117c191e0836d88a89a3")

    add_deps("cmake", "libpng", "boost")
    if is_plat("windows") then
        add_deps("eigen 3.3.x")
    else
        add_deps("pkg-config", "eigen")
    end
    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            io.replace("libfive/src/CMakeLists.txt", "EIGEN_INCLUDE_DIRS", "EIGEN3_INCLUDE_DIRS", {plain = true})
            io.replace("CMakeLists.txt", "%/MD.", "")
        end
        io.replace("libfive/src/CMakeLists.txt", "bash -c \"git diff --quiet --exit-code || echo +\"", "git diff --quiet --exit-code", {plain = true})
        io.replace("libfive/src/CMakeLists.txt", "${GIT_REV}${GIT_DIFF}", "${GIT_REV}+${GIT_DIFF}", {plain = true})
        io.replace("libfive/src/CMakeLists.txt", "if ?%(UNIX%)", "if (TRUE)")
        local configs = {"-DBUILD_GUILE_BINDINGS=OFF", "-DBUILD_PYTHON_BINDINGS=OFF", "-DBUILD_STUDIO_APP=OFF", "-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libfive_mesh_delete", {includes = "libfive.h"}))
    end)
