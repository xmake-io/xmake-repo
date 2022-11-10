package("raw_pdb")
    set_homepage("https://github.com/MolecularMatters/raw_pdb")
    set_description("A C++11 library for reading Microsoft Program DataBase PDB files")

    add_urls("https://github.com/MolecularMatters/raw_pdb.git")
    add_versions("2022.10.17", "e6f9d2104025ad152d68517b3f4c31cc7c2334a4")

    add_deps("cmake")

    on_install("windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("src/CMakeLists.txt", "add_subdirectory(Examples)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
        os.cp("src/*.h", package:installdir("include"))
        os.cp("src/Foundation/*.h", package:installdir("include/Foundation"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("PDB::ValidateFile(0)", {includes = "PDB.h"}))
    end)
