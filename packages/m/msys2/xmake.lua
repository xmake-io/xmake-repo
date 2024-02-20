package("msys2")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_urls("https://github.com/msys2/msys2-installer/releases/download/$(version).tar.xz", {version = function (version)
            return version:gsub("%.", "-")  .. "/msys2-base-x86_64-" .. version:gsub("%.", "")
        end})
    add_versions("2024.01.13", "04456a44a956d3c0b5f9b6c754918bf3a8c3d87c858be7a0c94c9171ab13c58c")

    add_configs("msystem", {description = "Set msys2 system.", type = "string", values = {"MSYS", "MINGW32", "MINGW64", "UCRT64", "CLANG32", "CLANG64", "CLANGARM64"}})

    on_install("@windows|x64", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", "usr/bin")
        local msystem = package:config("msystem")
        if msystem then
            package:addenv("MSYSTEM", msystem)
        end
    end)

    on_test(function (package)
        print(os.getenv("PATH"))
        os.vrun("sh --version")
        os.vrun("perl --version")
        os.vrun("ls -l")
        os.vrun("grep --version")
        os.vrun("bash --version")
    end)
