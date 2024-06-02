package("vcpkg")
    set_homepage("https://github.com/microsoft/vcpkg")
    set_description("Vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS. This tool and ecosystem are constantly evolving, and we always appreciate contributions!")
    set_license("MIT")
-- https://github.com/microsoft/vcpkg/releases/tag/2024.05.24
    add_urls("https://github.com/microsoft/vcpkg/archive/refs/tags/$(version).tar.gz")
    add_versions("2024.05.24", "3034e534d4ed13e6e6edad3c331c0e9e3280f579dd4ba86151aa1e2896b85d31")

    --add_includedirs("include/crashpad", "include/crashpad/mini_chromium")
    --add_links("crashpad_client", "crashpad_util", "mini_chromium")

    --add_deps("cmake")
    --add_deps("libcurl")
    
    on_install("linux", "windows|x64", "windows|x86", function(package)
       
        local scriptpath = path.join(".",package:is_plat("linux") and "bootstrap-vcpkg.sh" or "bootstrap-vcpkg.bat")
        local exepath = path.join(".",package:is_plat("linux") and "vcpkg" or "vcpkg.exe")
        print("scriptpath:" .. scriptpath)
        os.run(scriptpath)
        os.cp(os.curdir(),package:installdir())
        os.cp(exepath,package:installdir())
        -- os.setenv("VCPKG_ROOT", package:installdir())
        package:setenv("VCPKG_ROOT", package:installdir())
        package:addenv("PATH", package:installdir())
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun(package:installdir() .. "/vcpkg --help")
        end
    end)
