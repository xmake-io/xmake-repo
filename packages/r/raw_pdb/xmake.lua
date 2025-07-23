package("raw_pdb")
    set_homepage("https://github.com/MolecularMatters/raw_pdb")
    set_description("A C++11 library for reading Microsoft Program DataBase PDB files")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/MolecularMatters/raw_pdb.git")

    add_versions("2024.08.27", "3d6ca630f7527716fd3345cbfc5e043c67bfd2a1")
    add_versions("2022.10.17", "e6f9d2104025ad152d68517b3f4c31cc7c2334a4")

    add_deps("cmake")

    on_install("!macosx and !iphoneos", function (package)
        local configs = {"-DRAWPDB_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        if package:gitref() or package:version():ge("2024.08.27") then
            io.replace("src/CMakeLists.txt", "if (UNIX)", "if(1)", {plain = true})
            import("package.tools.cmake").install(package, configs)
            if is_host("windows") then
                os.trycp("raw_pdb.natvis", package:installdir("include/natvis"))
            end
        else
            io.replace("src/CMakeLists.txt", "add_subdirectory(Examples)", "", {plain = true})
            import("package.tools.cmake").build(package, configs)

            os.cp("src/*.h", package:installdir("include"))
            os.cp("src/Foundation/*.h", package:installdir("include/Foundation"))
            os.trycp("**.a", package:installdir("lib"))
            os.trycp("**.so", package:installdir("lib"))
            os.trycp("**.dylib", package:installdir("lib"))
            os.trycp("**.dll", package:installdir("bin"))
            os.trycp("**.lib", package:installdir("lib"))
            if package:config("shared") then
                os.trycp("**.pdb", package:installdir("bin"))
            else
                os.trycp("**.pdb", package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        if package:gitref() or package:version():ge("2024.08.27") then
            assert(package:has_cxxfuncs("PDB::ValidateFile(0, 0)", {includes = {"cstddef", "raw_pdb/PDB.h"}}))
        else
            assert(package:has_cxxfuncs("PDB::ValidateFile(0)", {includes = "PDB.h"}))
        end
    end)
