package("vcpkg")
    set_kind("binary")
    set_homepage("https://github.com/microsoft/vcpkg")
    set_description("C++ Library Manager for Windows, Linux, and MacOS")
    set_license("MIT")

    add_urls("https://github.com/microsoft/vcpkg/archive/refs/tags/$(version).tar.gz")
    add_versions("2024.09.30", "02a8f2e70e61d02401ec9f04906996549c270f6bdc788a82f830e0a87768543e")
    add_versions("2024.08.23", "d5c63c3ebaa715de71349e08c2af547e164c971f8acfaf62f7ee0fa6c1933f8d")
    add_versions("2024.07.12", "7da785e42b7487fb0e7465188f12c6ce0dfa760ab334d0f4f708bd1fc54081b1")
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
