package("glob")
    set_homepage("https://github.com/p-ranav/glob")
    set_description("Glob for C++17")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/glob.git")

    add_versions("2024.04.18", "d025092c0e1eb1a8b226d3a799fd32680d2fd13f")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("ghc_filesystem", {description = "Use ghc::filesystem instead of std::filesystem", default = false, type = "boolean"})
    
    on_load(function (package)
        if package:config("ghc_filesystem") then
            package:add("deps", "ghc_filesystem")
            package:add("defines", "GLOB_USE_GHC_FILESYSTEM")
        end
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("single_include/glob", package:installdir("include"))
        else
            local configs = {}
            if package:config("ghc_filesystem") then
                configs.ghc_filesystem = true
            end
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                option("ghc_filesystem", {default = false, showmenu = true, description = "Use ghc_filesystem"})
                if has_config("ghc_filesystem") then
                    add_requires("ghc_filesystem")
                    add_defines("GLOB_USE_GHC_FILESYSTEM")
                end
                target("glob")
                    set_kind("$(kind)")
                    set_languages("cxx17")
                    if has_config("ghc_filesystem") then
                        add_packages("ghc_filesystem")
                    end
                    add_headerfiles("include/(glob/*.h)")
                    add_files("source/*.cpp")
                    add_includedirs("include", {public = true})
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
            ]])
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                glob::glob("~/.b*");
            }
        ]]}, {configs = {languages = "cxx17"}, includes = package:config("header_only") and "glob/glob.hpp" or "glob/glob.h"}))
    end)
