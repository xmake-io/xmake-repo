package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")

    -- note that the version passed to add_versions is the Rust toolchain version, but the hash is the one of rustup-init executable
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
        local argv = {"--no-modify-path", "--profile", "minimal", "-y", "--default-toolchain=" .. package:version():shortstr()}
        local envs = {RUSTUP_HOME = path.absolute(".rustup"), CARGO_HOME = path.absolute(".cargo"), RUSTUP_INIT_SKIP_PATH_CHECK = "yes"}
        if is_host("windows") then
            os.vrunv(package:originfile(), argv, {envs = envs})
        else
            os.vrunv(package:originfile(), argv, {envs = envs, shell = true})
        end
        local installdir = package:installdir()
        os.mv(".rustup", installdir)
        os.mv(".cargo", installdir)
        package:addenv("PATH", ".cargo/bin")
        package:addenv("RC", ".cargo/bin/rustc" .. (is_host("windows") and ".exe" or ""))
        -- setup toolchain
        os.cd(installdir)
        os.addenv("PATH", path.absolute(".cargo/bin"))
        os.vrunv("rustup", { "default", package:version():shortstr() })
    end)

    on_test(function (package)
        os.vrun("cargo --version")
    end)
