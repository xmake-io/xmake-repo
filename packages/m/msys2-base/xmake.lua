package("msys2-base")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_urls("https://github.com/msys2/msys2-installer/releases/download/$(version).tar.xz", {version = function (version)
            return version:gsub("%.", "-")  .. "/msys2-base-x86_64-" .. version:gsub("%.", "")
        end})

    add_versions("2025.08.30", "780d7546aa86b781e0ded37c7b8f71f1b8572219494fe88259d8d4b78752b2e2")
    add_versions("2024.01.13", "04456a44a956d3c0b5f9b6c754918bf3a8c3d87c858be7a0c94c9171ab13c58c")

    set_policy("package.precompiled", false)

    on_install("@windows|x64", function (package)
        -- reduce time required to install packages by disabling pacman's disk space checking
        io.gsub("etc/pacman.conf", "^CheckSpace", "#CheckSpace")

        -- disable key refresh
        io.replace("etc/post-install/07-pacman-key.post", "--refresh-keys", "--version", {plain = true})

        -- install files
        os.cp("*", package:installdir())
        package:addenv("PATH", "usr/bin")

        -- starting MSYS2 for the first time
        local bash = path.join(package:installdir("usr/bin"), "bash.exe")
        os.vrunv(bash, {"-leo", "pipefail", "-c", "uname -a"})

        local pacman_update_cmd = "pacman --noconfirm -Syuu --overwrite '*'"
        -- updating packages
        try { function () os.vrunv(bash, {"-leo", "pipefail", "-c", pacman_update_cmd}) end}

        -- killing remaining tasks
        os.vrunv("taskkill", {"/F", "/FI", "MODULES eq msys-2.0.dll"})

        -- final system upgrade
        os.vrunv(bash, {"-leo", "pipefail", "-c", pacman_update_cmd})
    end)

    on_test(function (package)
        os.vrun("sh --version")
        os.vrun("perl --version")
        os.vrun("ls -l")
        os.vrun("grep --version")
        os.vrun("uname -a")
    end)
