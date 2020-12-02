package("eastl")

    set_homepage("https://github.com/electronicarts/EASTL")
    set_description("EASTL stands for Electronic Arts Standard Template Library.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/electronicarts/EASTL/archive/$(version).tar.gz")
    add_versions("3.17.03", "50a072066e30fda364d482df6733572d8ca440a33825d81254b59a6ca9f4375a")

    add_deps("cmake")
    add_deps("eabase")

    on_install("windows", "linux", "macosx", function (package)
        io.gsub("CMakeLists.txt", "add_subdirectory%(test/packages/EABase%)", "#")
        local configs = {}
        table.insert(configs, "-DEASTL_BUILD_BENCHMARK:BOOL=OFF")
        import("package.tools.cmake").build(package, configs, {buildir = "build", packagedeps = "eabase"})
        if package:is_plat("windows") then
            os.trycp("build/*.lib", package:installdir("lib"))
            os.trycp("build/*.dll", package:installdir("bin"))
        else
            os.trycp("build/*.a", package:installdir("lib"))
            os.trycp("build/*.so", package:installdir("lib"))
        end
        os.cp("include/EASTL", package:installdir("include"))
    end)


    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                eastl::vector<int> testInt{};
            }
        ]]},{configs = {languages = "c++17"}, includes = "EASTL/vector.h"}))
    end)