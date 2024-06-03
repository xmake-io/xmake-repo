package("vcpkg")
    set_homepage("https://github.com/microsoft/vcpkg")
    set_description("Vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/vcpkg/archive/refs/tags/$(version).tar.gz")
    add_versions("2024.05.24", "3034e534d4ed13e6e6edad3c331c0e9e3280f579dd4ba86151aa1e2896b85d31")

    add_deps("zip", "unzip", "cmake", "ninja", "libcurl")

    on_install("linux", "windows|x64", "windows|x86", function(package)
        local scriptpath =  package:is_plat("linux") and "./bootstrap-vcpkg.sh" or "bootstrap-vcpkg.bat"
        os.run(scriptpath)
        os.cp(".", package:installdir())
        package:setenv("VCPKG_ROOT", ".")
        package:addenv("PATH", ".")
        package:mark_as_pathenv("VCPKG_ROOT")
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun("vcpkg --help")
        end
    end)
