package("vcpkg")
    set_kind("binary")
    set_homepage("https://github.com/microsoft/vcpkg")
    set_description("Vcpkg helps you manage C and C++ libraries on Windows, Linux and MacOS.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/vcpkg/archive/refs/tags/$(version).tar.gz")
    add_versions("2024.05.24", "3034e534d4ed13e6e6edad3c331c0e9e3280f579dd4ba86151aa1e2896b85d31")

    add_deps("zip", "unzip", "cmake", "ninja", "curl")

    on_install("@linux", "@macosx", "@windows", function(package)
        if package:is_plat("windows") then
            os.vrun("bootstrap-vcpkg.bat")
        else
            os.vrunv("./bootstrap-vcpkg.sh", {shell = true})
        end
        os.cp(".", package:installdir())
        package:setenv("VCPKG_ROOT", ".")
        package:addenv("PATH", ".")
        package:mark_as_pathenv("VCPKG_ROOT")
    end)

    on_test(function(package)
        os.vrun("vcpkg --help")
    end)
