package("msys2")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_deps("msys2-base")

    add_configs("msystem", {description = "Set msys2 system.", type = "string", values = {"MSYS", "MINGW32", "MINGW64", "UCRT64", "CLANG32", "CLANG64", "CLANGARM64"}})
    add_configs("pathtype", {description = "Set path type.", default = "inherit", type = "string", values = {"inherit"}})

    add_configs("make", {description = "Install gnumake.", default = false, type = "boolean"})
    add_configs("gcc", {description = "Install gcc.", default = false, type = "boolean"})
    add_configs("uchardet", {description = "Install uchardet.", default = false, type = "boolean"})
    add_configs("diffutils", {description = "Install diffutils.", default = false, type = "boolean"})
    add_configs("base_devel", {description = "Install base-devel.", default = false, type = "boolean"})
    add_configs("mingw64_gcc", {description = "Install mingw64 gcc.", default = false, type = "boolean"})
    add_configs("mingw64_toolchain", {description = "Install mingw64 toolchain.", default = false, type = "boolean"})
    add_configs("mingw32_gcc", {description = "Install mingw32 gcc.", default = false, type = "boolean"})
    add_configs("mingw32_toolchain", {description = "Install mingw32 toolchain.", default = false, type = "boolean"})

    set_policy("package.precompiled", false)

    on_install("@windows|x64", function (package)
        local msys2_base = package:dep("msys2-base")
        local bash = path.join(msys2_base:installdir("usr/bin"), "bash.exe")
        local msystem = package:config("msystem")
        if msystem then
            package:addenv("MSYSTEM", msystem)
            if msystem == "MINGW64" then
                package:addenv("PATH", msys2_base:installdir("mingw64/bin"))
            elseif msystem == "MINGW32" then
                package:addenv("PATH", msys2_base:installdir("mingw32/bin"))
            end
        end
        local pathtype = package:config("pathtype")
        if pathtype then
            package:addenv("MSYS2_PATH_TYPE", pathtype)
        end
        package:addenv("CHERE_INVOKING", "1")

        -- install additional packages
        local packages = {
            "gcc", "make", "diffutils",
            base_devel = "base-devel",
            uchardet = "mingw-w64-x86_64-uchardet",
            mingw32_gcc = "mingw-w64-i686-gcc",
            mingw32_toolchain = "mingw-w64-i686-toolchain",
            mingw64_gcc = "mingw-w64-x86_64-gcc",
            mingw64_toolchain = "mingw-w64-x86_64-toolchain"}
        for k, v in pairs(packages) do
            local configname = type(k) == "number" and v or k
            local packagename = v
            if package:config(configname) then
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
                if package:config("mingw64_gcc") or package:config("mingw64_toolchain") then
                    os.vrun("x86_64-w64-mingw32-gcc --version")
                end
            elseif msystem == "MINGW32" then
                if package:config("mingw32_gcc") or package:config("mingw32_toolchain") then
                    os.vrun("i686-w64-mingw32-gcc --version")
                end
            end
        end
    end)
