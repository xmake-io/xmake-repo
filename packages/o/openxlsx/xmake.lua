package("openxlsx")
    set_homepage("https://github.com/troldal/OpenXLSX")
    set_description("A C++ library for reading, writing, creating and modifying Microsoft Excel® (.xlsx) files.")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/troldal/OpenXLSX.git")

    add_versions("2024.10.17", "d618e1de159cfb4fb3bf97934319fe8b7bed350e")

    add_configs("compact_mode", {description = "Build library in compact mode (slower, but uses less memory)", default = false, type = "boolean"})

    add_deps("cmake")

    add_includedirs("include", "include/OpenXLSX/headers")

    on_install(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "OPENXLSX_STATIC_DEFINE")
        end

        if not package:config("lto") then
            io.replace("CMakeLists.txt", "set_property(TARGET OpenXLSX PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)", "", {plain = true})
        end
        if package:is_plat("mingw") then
            io.replace("OpenXLSX/sources/XLDocument.cpp", "#    define stat _stat", "", {plain = true})
        end

        local configs = {
            "-DOPENXLSX_CREATE_DOCS=OFF",
            "-DOPENXLSX_BUILD_SAMPLES=OFF",
            "-DOPENXLSX_BUILD_TESTS=OFF",
            "-DOPENXLSX_BUILD_BENCHMARKS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DOPENXLSX_LIBRARY_TYPE=" .. (package:config("shared") and "SHARED" or "STATIC"))
        table.insert(configs, "-DOPENXLSX_COMPACT_MODE=" .. (package:config("compact_mode") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)

        os.vcp("OpenXLSX/external", package:installdir("include"))
        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "**.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                OpenXLSX::XLDocument doc;
                doc.close();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "OpenXLSX/OpenXLSX.hpp"}))
    end)
