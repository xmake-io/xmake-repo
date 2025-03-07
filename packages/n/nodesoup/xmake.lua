package("nodesoup")
    set_homepage("https://github.com/olvb/nodesoup")
    set_description("Force-directed graph layout with Fruchterman-Reingold")
    set_license("Unlicense")

    add_urls("https://github.com/olvb/nodesoup.git")
    add_versions("2020.09.05", "3158ad082bb0cd1abee75418b12b35522dbca74f")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "ARCHIVE DESTINATION lib", "ARCHIVE DESTINATION lib\nRUNTIME DESTINATION bin", {plain = true})
            io.replace("src/CMakeLists.txt", "nodesoup PROPERTIES POSITION_INDEPENDENT_CODE ON", "nodesoup PROPERTIES", {plain = true})
            local configs = {"-DBUILD_DEMO=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:config("shared") and package:is_plat("windows") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
            import("package.tools.cmake").install(package, configs)
            -- keep include/nodesoup.hpp and include/nodesoup/nodesoup.hpp header tree
            os.vcp("include", package:installdir())
        else
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                target("nodesoup")
                    set_kind("$(kind)")
                    set_languages("c++14")
                    add_files("src/*.cpp")
                    add_includedirs("include")
                    add_headerfiles("include/nodesoup.hpp")
                    add_defines("_USE_MATH_DEFINES")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nodesoup::size_radiuses({{}});
            }
        ]]}, {configs = {languages = "c++14"}, includes = "nodesoup.hpp"}))
    end)
