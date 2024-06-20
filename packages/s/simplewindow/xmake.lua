package("simplewindow")

    set_homepage("https://github.com/Mzying2001/sw")
    set_description("SimpleWindow GUI Framework")

    add_urls("https://github.com/Mzying2001/sw.git")
    add_versions("2024.06.20", "894db9de8a43b83f76dca921eeeb372cb7a640b0")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_ldflags("/LTCG")
    add_shflags("/LTCG")
    add_syslinks("user32", "gdi32", "shell32")


    on_install("windows", function (package)
        local configs = {"vs/sw.sln"}
        table.insert(configs, "/p:Platform=" .. (package:is_arch("x64") and "x64" or "Win32"))

        local vs_runtime = package:runtimes()
        local profilename
        if vs_runtime == "MT" then
            if package:debug() then
                table.insert(configs, "/p:Configuration=" .. "Debug_MT")
                profilename = "Debug_MT"
            else
                table.insert(configs, "/p:Configuration=" .. "Release_MT")
                profilename = "Release_MT"
            end
        else
            table.insert(configs, "/p:Configuration=" .. (package:debug() and "Debug" or "Release"))
        end

        import("package.tools.msbuild").build(package, configs)
        os.mkdir(package:installdir("include") .. "/sw")
        os.cp("sw/inc/*.h", package:installdir("include") .. "/sw")

        local outputdir = path.join("vs", "bin", package:is_arch("x64") and "x64" or "Win32", profilename)
        os.cp(outputdir .. "/*", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sw::Window mainWindow;
            }
        ]]}, {includes = "sw/SimpleWindow.h"}))
    end)
