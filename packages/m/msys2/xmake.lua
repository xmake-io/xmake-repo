package("msys2")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_deps("msys2-base")

    add_configs("msystem", {description = "Set msys2 system.", type = "string", values = {"MSYS", "MINGW32", "MINGW64", "UCRT64", "CLANG32", "CLANG64", "CLANGARM64"}})

    on_install("@windows|x64", function (package)
        local msystem = package:config("msystem")
        if msystem then
            package:addenv("MSYSTEM", msystem)
        end
    end)

    on_test(function (package)
        os.vrun("sh --version")
        os.vrun("perl --version")
        os.vrun("ls -l")
        os.vrun("grep --version")
        os.vrun("uname -a")
    end)
