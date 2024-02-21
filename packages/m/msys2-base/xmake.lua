package("msys2-base")
    set_kind("toolchain")
    set_homepage("https://www.msys2.org/")
    set_description("Software Distribution and Building Platform for Windows")

    add_urls("https://github.com/msys2/msys2-installer/releases/download/$(version).tar.xz", {version = function (version)
            return version:gsub("%.", "-")  .. "/msys2-base-x86_64-" .. version:gsub("%.", "")
        end})
    add_versions("2024.01.13", "04456a44a956d3c0b5f9b6c754918bf3a8c3d87c858be7a0c94c9171ab13c58c")

    on_install("@windows|x64", function (package)
        -- reduce time required to install packages by disabling pacman's disk space checking
        io.gsub("etc/pacman.conf", "^CheckSpace", "#CheckSpace")

        -- disable key refresh
        io.replace("etc/post-install/07-pacman-key.post", "--refresh-keys", "--version", {plain = true})

        -- install files
        os.cp("*", package:installdir())
        package:addenv("PATH", "usr/bin")

        -- updating packages
        local pacman = path.join(package:installdir("usr/bin"), "pacman.exe")
        try { function () os.vrunv(pacman, {"-Syuu", "--overwrite", "*"}) end}

        -- killing remaining tasks
        os.vrunv("taskkill", {"/F", "/FI", "MODULES eq msys-2.0.dll"})

        -- final system upgrade
        os.vrunv(pacman, {"-Syuu", "--overwrite", "*"})
    end)

    on_test(function (package)
        os.vrun("sh --version")
        os.vrun("perl --version")
        os.vrun("ls -l")
        os.vrun("grep --version")
        os.vrun("uname -a")
    end)
