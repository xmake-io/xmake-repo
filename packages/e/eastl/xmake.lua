package("eastl")

    set_homepage("https://github.com/electronicarts/EASTL")
    set_description("EASTL stands for Electronic Arts Standard Template Library.")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/electronicarts/EASTL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/electronicarts/EASTL.git")
    add_versions("3.27.01", "fce43bf443f5569b00a8deae735394ea0b16f6c3f96867a17ded50775ffcdd12")
    add_versions("3.17.03", "50a072066e30fda364d482df6733572d8ca440a33825d81254b59a6ca9f4375a")
    add_versions("3.17.06", "9ebeef26cdf091877ee348450d2711cd0bb60ae435309126c0adf8fec9a01ea5")
    add_versions("3.18.00", "a3c5b970684be02e81fb16fbf92ed2584e055898704fde87c72d0331afdea12b")
    add_versions("3.21.12", "2a4d77e5eda23ec52fea8b22abbf2ea8002f38396d2a3beddda3ff2e17f7db2e")
    add_versions("3.21.23", "2bcb48f88f7daf9f91c165aae751c10d11d6959b6e10f2dda8f1db893e684022")
    add_versions("3.27.00", "5606643e41ab12fd7c209755fe04dca581ed01f43dec515288b1544eea22623f")

    add_deps("cmake")
    add_deps("eabase")

    on_check("mingw", function (package)
        if package:version():lt("3.27.00") then
            raise("package(eastl): MinGW is unsupported for version less than 3.27.00")
        end
    end)

    on_load("windows", "mingw", function (package)
        if package:config("shared") then
            package:add("defines", "EA_DLL")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        io.replace("CMakeLists.txt", [[target_compile_features(EASTL PUBLIC cxx_std_14)]], [[target_compile_features(EASTL PUBLIC cxx_std_17)]], {plain = true})
        if package:is_plat("windows", "mingw") and package:config("shared") then
            io.replace("CMakeLists.txt", [[add_definitions(-D_CHAR16T)]], [[add_definitions(-D_CHAR16T)
if(BUILD_SHARED_LIBS)
  target_compile_definitions(EASTL PUBLIC EA_DLL)
  if(WIN32)
    target_compile_definitions(EASTL PRIVATE "EASTL_API=__declspec(dllexport)")
  endif()
endif()]], {plain = true})
        end
        io.replace("CMakeLists.txt", "add_subdirectory(test/packages/EABase)", "", {plain = true})
        io.replace("CMakeLists.txt", "target_link_libraries(EASTL EABase)", "", {plain = true})
        local configs = {"-DEASTL_BUILD_TESTS=OFF", "-DEASTL_BUILD_BENCHMARK=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "eabase"})
        os.cp("include/EASTL", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                eastl::vector<int> testInt{};
            }
        ]]},{configs = {languages = "c++17"}, includes = "EASTL/vector.h"}))
    end)
