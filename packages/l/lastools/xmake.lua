package("lastools")
    set_homepage("https://github.com/LAStools/LAStools")
    set_description("efficient tools for LiDAR processing")
    set_license("LGPL-2.0")

    add_urls("https://github.com/LAStools/LAStools/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LAStools/LAStools.git")

    add_versions("v2.0.3", "b6c6ac33835ead2c69d05e282febc266048ba071a71dae6fdad321d532dfcf78")

    add_configs("cmake", {description = "Use cmake buildsystem", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "USE_AS_DLL")
        end
    end)

    on_install(function (package)
        local enable_tools = package:config("tools")
        if package:config("cmake") then
            if not enable_tools then
                io.replace("CMakeLists.txt", "add_subdirectory(src)", "", {plain = true})
            end
    
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    
            local opt = {}
            opt.cxflags = "/utf-8"
            import("package.tools.cmake").install(package, configs, opt)

            os.cp("LASlib/lib/*.lib", package:installdir("lib"))
            os.cp("LASlib/lib/*.dll", package:installdir("bin"))
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {tools = enable_tools})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <LASlib/lasreader.hpp>
            #include <LASlib/laswriter.hpp>
            void test() {
                LASreadOpener lasreadopener;
                LASwriteOpener laswriteopener;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
