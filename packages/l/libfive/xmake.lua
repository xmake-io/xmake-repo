package("libfive")

    set_homepage("https://libfive.com/")
    set_description("libfive is a software library and set of tools for solid modeling, especially suited for parametric and procedural design.")

    add_urls("https://github.com/libfive/libfive.git")
    add_versions("20210408", "e6a6448694f2204b003e29bba45754461261b9b2")

    add_deps("cmake", "eigen", "libpng", "boost")
    if not is_plat("windows") then
        add_deps("pkg-config")
    end
    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            io.replace("libfive/src/CMakeLists.txt", "EIGEN_INCLUDE_DIRS", "EIGEN3_INCLUDE_DIRS", {plain = true})
            io.replace("libfive/src/CMakeLists.txt", "if (UNIX)", "if (true)", {plain = true})
            io.replace("CMakeLists.txt", "%/MD.", "")
        end
        io.replace("libfive/include/libfive.h", "[[deprecated(\"use libfive_tree_nullary instead\")]]", "", {plain = true})
        io.replace("libfive/src/CMakeLists.txt", "bash -c \"git diff --quiet --exit-code || echo +\"", "echo +", {plain = true})
        local configs = {"-DBUILD_GUILE_BINDINGS=OFF", "-DBUILD_PYTHON_BINDINGS=OFF", "-DBUILD_STUDIO_APP=OFF", "-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp("libfive/include", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libfive_mesh_delete", {includes = "libfive.h"}))
    end)
