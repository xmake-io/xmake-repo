package("vcpkg")
    set_kind("binary")
    set_homepage("https://github.com/microsoft/vcpkg")
    set_description("C++ Library Manager for Windows, Linux, and MacOS")
    set_license("MIT")

    add_urls("https://github.com/microsoft/vcpkg/archive/refs/tags/$(version).tar.gz")
    add_versions("2025.12.12", "fd3aedfae4d80fc9af5b2c4598ccc697586c7fda52e77c9a993f2ec2b4622d98")
    add_versions("2025.10.17", "bcbae273e5a589c5722178bcfa1787e7177a2c9938db82fb57e9675be9924e62")
    add_versions("2025.07.25", "dff617c636a6519d4f083e658d404970c9da7d940a974e1d17f855f26a334e2f")
    add_versions("2024.11.16", "ec932ad758fb2b3aefc0d712d4bde8d913cd97ad2a0067d52f23d05c31b42aa0")
    add_versions("2024.10.21", "879ff57284d0bdcab127315a994cf571de4c1c72a0f7a80b770c3e3714d1649b")
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
