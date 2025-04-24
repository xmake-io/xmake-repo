package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")

    if is_host("windows") then
        add_urls("https://static.rust-lang.org/rustup/archive/1.28.1/x86_64-pc-windows-msvc/rustup-init.exe")

        add_versions("1.86.0", "7b83039a1b9305b0c50f23b2e2f03319b8d7859b28106e49ba82c06d81289df6")
    else
        add_urls("https://raw.githubusercontent.com/rust-lang/rustup/refs/tags/1.28.1/rustup-init.sh")

        add_versions("1.86.0", "b25b33de9e5678e976905db7f21b42a58fb124dd098b35a962f963734b790a9b")
    end

    if is_host("linux") then
        add_extsources("apt::rustup")
        add_extsources("pacman::rustup")
    elseif is_host("macosx") then
        add_extsources("brew::rustup")
    end

    on_install(function (package)
        local cachedir = package:cachedir()
        if is_host("windows") then
            os.execv(package:originfile(), { "--no-modify-path", "--profile", "minimal", "--quiet", "-y", "--default-toolchain=" .. package:version():shortstr() }, { envs = { RUSTUP_HOME = path.join(cachedir, ".rustup"), CARGO_HOME = path.join(cachedir, ".cargo") } })
        else
            local envs = {
                CARGO_HOME = path.join(cachedir, ".cargo"),
                RUSTUP_HOME = path.join(cachedir, ".rustup"),
                RUSTUP_INIT_SKIP_PATH_CHECK = "yes"
            }
            os.vrunv(os.shell(), { path.join(cachedir, "rustup-init.sh"), "--no-modify-path", "--profile", "minimal", "--quiet", "-y", "--default-toolchain=" .. package:version():shortstr() }, { envs = envs })
        end
        local installdir = package:installdir()
        os.mv(path.join(cachedir, ".rustup"), installdir)
        os.mv(path.join(cachedir, ".cargo"), installdir)
        package:addenv("PATH", ".cargo/bin")
        package:addenv("RC", ".cargo/bin/rustc" .. (is_host("windows") and ".exe" or ""))
        -- setup toolchain
        os.cd(installdir)
        os.addenv("PATH", path.join(installdir, ".cargo/bin"))
        os.vrunv("rustup", { "default", package:version():shortstr() })
    end)

    on_test(function (package)
        os.vrun("cargo --version")
    end)
