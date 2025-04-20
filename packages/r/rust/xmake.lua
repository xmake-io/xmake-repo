package("rust")
    set_kind("binary")
    set_homepage("https://rust-lang.org")

    if is_host("windows") then
        add_urls("https://static.rust-lang.org/rustup/archive/$(version)/x86_64-pc-windows-msvc/rustup-init.exe")

        add_versions("1.28.1", "7b83039a1b9305b0c50f23b2e2f03319b8d7859b28106e49ba82c06d81289df6")
    end

    if is_host("linux") then
        add_extsources("apt::rustup")
        add_extsources("pacman::rustup")
    elseif is_host("macosx") then
        add_extsources("brew::rustup")
    end

    on_install("@windows", function (package)
        local cachedir = package:cachedir()
        local installdir = package:installdir()
        os.execv(package:originfile(), { "--no-modify-path", "--profile", "minimal", "--quiet", "-y" }, { envs = { RUSTUP_HOME = path.join(cachedir, ".rustup"), CARGO_HOME = path.join(cachedir, ".cargo") } })
        os.mv(path.join(cachedir, ".rustup", "toolchains", "*", "*"), installdir)
        package:addenv("PATH", path.join(installdir, "bin"))
    end)

    on_install("!windows", function (package)
        local cachedir = path.join(package:cachedir(), ".rustdir")
        local installdir = package:installdir()
        local outdata, _ = os.iorun("curl https://sh.rustup.rs -sSf")
        io.writefile(path.join(cachedir, "rustup-init.sh"), outdata)
        os.execv(os.shell(), { path.join(cachedir, "rustup-init.sh"), "--no-modify-path", "--profile", "minimal", "--quiet", "-y" }, { envs = { RUSTUP_HOME = path.join(cachedir, ".rustup"), CARGO_HOME= path.join(cachedir, ".cargo") } })
        os.mv(path.join(cachedir, ".rustup", "toolchains", "*", "*"), installdir)
        package:addenv("PATH", path.join(installdir, "bin"))
    end)

    on_test(function (package)
        assert(os.execv("cargo", { "--version" }))
    end)
