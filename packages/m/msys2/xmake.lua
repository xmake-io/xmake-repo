package("msys2")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_deps("msys2-base")

    add_configs("msystem", {description = "Set msys2 system.", type = "string", values = {"MSYS", "MINGW32", "MINGW64", "UCRT64", "CLANG32", "CLANG64", "CLANGARM64"}})
    add_configs("pathtype", {description = "Set path type.", default = "inherit", type = "string", values = {"inherit"}})

    add_configs("make", {description = "Install gnumake.", default = false, type = "boolean"})
    add_configs("diffutils", {description = "Install diffutils.", default = false, type = "boolean"})

    set_policy("package.precompiled", false)

    on_install("@windows|x64", function (package)
        local bash = path.join(msys2_base:installdir("usr/bin"), "bash.exe")
        local msys2_base = package:dep("msys2-base")
        local msystem = package:config("msystem")
        if msystem then
            package:addenv("MSYSTEM", msystem)
            if msystem == "MINGW64" then
                os.vrunv(bash, {"-leo", "pipefail", "-c", "pacman --noconfirm -S --needed --overwrite * mingw-w64-x86_64-toolchain"})
                package:addenv("PATH", msys2_base:installdir("mingw64/bin"))
            elseif msystem == "MINGW32" then
                os.vrunv(bash, {"-leo", "pipefail", "-c", "pacman --noconfirm -S --needed --overwrite * mingw-w64-i686-toolchain"})
                package:addenv("PATH", msys2_base:installdir("mingw32/bin"))
            end
        end
        local pathtype = package:config("pathtype")
        if pathtype then
            package:addenv("MSYS2_PATH_TYPE", pathtype)
        end
        package:addenv("CHERE_INVOKING", "1")

        -- install additional packages
        local packages = {"make", "diffutils"}
        for _, packagename in ipairs(packages) do
            if package:config(packagename) then
                os.vrunv(bash, {"-leo", "pipefail", "-c", "pacman --noconfirm -S --needed --overwrite * " .. packagename})
            end
        end
    end)

    on_test(function (package)
        os.vrun("sh --version")
        os.vrun("perl --version")
        os.vrun("ls -l")
        os.vrun("grep --version")
        os.vrun("uname -a")
        local msystem = package:config("msystem")
        if msystem then
            if msystem == "MINGW64" then
                os.vrun("x86_64-w64-mingw32-gcc --version")
            elseif msystem == "MINGW32" then
                os.vrun("i686-w64-mingw32-gcc --version")
            end
        end
    end)
