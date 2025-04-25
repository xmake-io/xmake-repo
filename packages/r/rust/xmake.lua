package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")
    set_description("Rust is a general-purpose programming language emphasizing performance, type safety, and concurrency.")

    add_versions("1.86.0", "")

    if is_host("linux") then
        add_extsources("apt::rustup")
        add_extsources("pacman::rustup")
    elseif is_host("macosx") then
        add_extsources("brew::rustup")
    end

    add_deps("rustup-init", {private = true})

    on_install("@windows|x86", "@windows|x64", "@windows|arm64", "@msys", "@cygwin", "@bsd", "@linux", "@macosx", function (package)
        local argv = {"--no-modify-path", "--profile=minimal", "--default-toolchain=" .. package:version():shortstr(), "-y"}
        local envs = {RUSTUP_HOME = path.absolute(".rustup"), CARGO_HOME = path.absolute(".cargo"), RUSTUP_INIT_SKIP_PATH_CHECK = "yes"}
        if is_host("windows") then
            os.vrunv("rustup-init.exe", argv, {envs = envs})
        else
            os.vrunv("rustup-init.sh", argv, {envs = envs, shell = true})
        end
        local installdir = package:installdir()
        os.mv(".rustup", installdir)
        os.mv(".cargo", installdir)
        -- setup toolchain
        os.cd(installdir)
        os.addenv("PATH", path.absolute(".cargo/bin"))
        os.vrunv("rustup", { "default", package:version():shortstr() })
        package:addenv("PATH", ".cargo/bin")
        package:addenv("RC", ".cargo/bin/rustc" .. (is_host("windows") and ".exe" or ""))
    end)

    on_test(function (package)
        os.vrun("cargo --version")
    end)
