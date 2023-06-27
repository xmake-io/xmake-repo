package("partio")

    set_homepage("http://partio.us/")
    set_description("Partio is an open source C++ library for reading, writing and manipulating a variety of standard particle formats (GEO, BGEO, PTC, PDB, PDA).")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/wdas/partio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wdas/partio.git")
    add_versions("v1.14.0", "f98874b781e92ab9b5d0575cabc437d27274cd91cb581f80960918efa491f902")
    add_versions("v1.14.6", "53a5754d6b2fc3e184953d985c233118ef0ab87169f34e3aec4a7e6d20cd9bd4")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("python", {description = "Enable python support.", default = false, type = "boolean"})
    add_configs("tools",  {description = "Build utility tools.", default = false, type = "boolean"})

    add_deps("cmake", "zlib")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("python") then
            package:add("deps", "swig", "python 3.x")
        end
        if package:config("tools") then
            package:add("deps", "freeglut", "opengl")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.gsub("CMakeLists.txt", "add%_subdirectory%(src/tests%)", "")
        io.gsub("CMakeLists.txt", "find%_package%(GLUT REQUIRED%)", "find_package(GLUT)")
        io.gsub("CMakeLists.txt", "find%_package%(OpenGL REQUIRED%)", "find_package(OpenGL)")
        io.gsub("CMakeLists.txt", "find%_package%(Python(.-) REQUIRED%)", "find_package(Python%1)")
        local configs = {"-DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPARTIO_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_SWIG=" .. (package:config("python") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_GLUT=" .. (package:config("tools") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
        if package:config("python") then
            local pyver = package:dep("python"):version()
            package:addenv("PYTHONPATH", path.join(package:installdir("lib"), format("python%d.%d", pyver:major(), pyver:minor()), "site-packages"))
        end
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Partio::ParticlesDataMutable* particles=Partio::createInterleave();
                particles->addParticles(10);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Partio.h"}))
        if package:config("python") then
            local python_exe = package:is_plat("windows") and "python" or "python3"
            os.vrunv(python_exe, {"-c", "import partio"})
        end
    end)
