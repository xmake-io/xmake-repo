package("eastl")

    set_homepage("https://github.com/electronicarts/EASTL")
    set_description("EASTL stands for Electronic Arts Standard Template Library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/electronicarts/EASTL/archive/$(version).tar.gz")
    add_versions("3.17.03", "50a072066e30fda364d482df6733572d8ca440a33825d81254b59a6ca9f4375a")
    add_versions("3.17.06", "9ebeef26cdf091877ee348450d2711cd0bb60ae435309126c0adf8fec9a01ea5")
    add_versions("3.21.12", "2a4d77e5eda23ec52fea8b22abbf2ea8002f38396d2a3beddda3ff2e17f7db2e")

    add_deps("cmake")
    add_deps("eabase")

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(test/packages/EABase)", "", {plain = true})
        io.replace("CMakeLists.txt", "target_link_libraries(EASTL EABase)", "", {plain = true})
        local configs = {"-DEASTL_BUILD_TESTS=OFF", "-DEASTL_BUILD_BENCHMARK=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if not package:is_plat("windows") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        end
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
