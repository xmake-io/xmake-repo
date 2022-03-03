package("partio")

    set_homepage("http://partio.us/")
    set_description("Partio is an open source C++ library for reading, writing and manipulating a variety of standard particle formats (GEO, BGEO, PTC, PDB, PDA).")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/wdas/partio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wdas/partio.git")
    add_versions("v1.14.0", "f98874b781e92ab9b5d0575cabc437d27274cd91cb581f80960918efa491f902")

    add_deps("cmake", "python", "zlib")
    on_install("windows", "macosx", "linux", function (package)
        io.gsub("CMakeLists.txt", "add%_subdirectory%(.+%)", "add_subdirectory(src/lib)")
        io.gsub("CMakeLists.txt", "find%_package%(GLUT REQUIRED%)", "")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Partio::ParticlesDataMutable* particles=Partio::createInterleave();
                particles->addParticles(10);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "Partio.h"}))
    end)
