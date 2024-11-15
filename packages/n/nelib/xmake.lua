package("nelib")
    set_kind("library", {moduleonly = true})
    set_homepage("https://github.com/hexne/nelib")
    set_description("A commonly used tool collection library")
    add_urls("https://github.com/hexne/NeLib.git")
    add_versions("2024.11.15", "ee9195d2b2612da06e0ac4aaa1f6c7cb6c94699a")
    add_configs("modules", {description = "Build with C++20 modules support.", default = false, type = "boolean"})
    add_configs("header_only", {description = "Build as a headeronly library.", default = false, type = "boolean"})
    set_policy("package.cmake_generator.ninja", true)
    add_deps("opencv")

    on_load(function (package)
        if not package:config("modules") then
            package:add("deps", "cmake")
            if package:config("header_only") then
                package:set("kind", "library", {headeronly = true})
            end
        end
    end)

    on_install("linux", function (package)
        if not package:config("modules") then
            os.cp("*.h", package:installdir("include"))
            if not package:config("header_only") then
                io.replace("CMakeLists.txt", "NOT GLM_DISABLE_AUTO_DETECTION", "FALSE")
                local configs = {"-DGLM_BUILD_TESTS=OFF"}
                table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
                import("package.tools.cmake").build(package, {configs , buildir = "build"})
                os.cp("**.pcm", package:installdir("include"))
                os.cp("**.a", package:installdir("lib"))
            end
        else
            io.writefile("xmake.lua", [[ 
                add_requires("opencv")
                target("nelib")
                    add_packages("opencv")
                    set_kind("$(kind)")
                    set_languages("c++20")
                    add_headerfiles("./**.h", {outputdir = 'nelib'})
                    add_includedirs(".")
                    add_files("**.cppm", {public = true})
            ]])
            import("package.tools.xmake").install(package)
        end

    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ;
            }
        ]]}, {configs = {languages = "c++20", includes = "nelib/tools.h"}}))
    end)
