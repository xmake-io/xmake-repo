package("rustup")
    set_kind("binary")
    set_homepage("https://rustup.rs")
    set_description("An installer for the systems programming language Rust")

    if is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://static.rust-lang.org/rustup/archive/$(version)/x86_64-pc-windows-msvc/rustup-init.exe", {filename = "rustup-init.exe"})

            add_versions("1.28.1", "7b83039a1b9305b0c50f23b2e2f03319b8d7859b28106e49ba82c06d81289df6")
        elseif os.arch() == "x86" then
            add_urls("https://static.rust-lang.org/rustup/archive/$(version)/i686-pc-windows-msvc/rustup-init.exe", {filename = "rustup-init.exe"})

            add_versions("1.28.1", "494bbeb52bd102891be4e7e5adc74eeb1c532adfdc33d51ae1aa9fd2ff5f1048")
        elseif os.arch() == "arm64" then
            add_urls("https://static.rust-lang.org/rustup/archive/$(version)/aarch64-pc-windows-msvc/rustup-init.exe", {filename = "rustup-init.exe"})

            add_versions("1.28.1", "9054ad509637940709107920176f14cee334bc5cfe50bc0a24a3dc59b6f4d458")
        end
    else
        add_urls("https://raw.githubusercontent.com/rust-lang/rustup/refs/tags/$(version)/rustup-init.sh", {filename = "rustup-init.sh"})

        add_versions("1.28.1", "b25b33de9e5678e976905db7f21b42a58fb124dd098b35a962f963734b790a9b")
    end

    if is_host("linux") then
        add_extsources("apt::rustup")
        add_extsources("pacman::rustup")
    elseif is_host("macosx") then
        add_extsources("brew::rustup")
    end

    on_load(function (package)
        package:addenv("PATH", path.join(".cargo", "bin"))
        package:setenv("CARGO_HOME", ".cargo")
        package:setenv("RUSTUP_HOME", ".rustup")
        package:mark_as_pathenv("CARGO_HOME")
        package:mark_as_pathenv("RUSTUP_HOME")
    end)

    on_install("@windows|x86", "@windows|x64", "@windows|arm64", "@msys", "@cygwin", "@bsd", "@linux", "@macosx", function (package)
        local installdir = package:installdir()
        local argv = {"--no-modify-path", "--no-update-default-toolchain", "--profile=minimal", "--default-toolchain=none", "-y"}
        local envs = {CARGO_HOME = path.join(installdir, ".cargo"), RUSTUP_HOME = path.join(installdir, ".rustup"), RUSTUP_INIT_SKIP_PATH_CHECK = "yes", RUSTUP_VERSION = package:version():shortstr()}
        os.vrunv(package:originfile(), argv, {envs = envs, shell = not is_host("windows")})
        os.vrunv(path.join(installdir, ".cargo", "bin", "rustup" .. (is_host("windows") and ".exe" or "")), {"set", "auto-self-update", "disable"}, {envs = envs})
    end)

    on_test(function (package)
        os.vrunv("rustup", {"--version"})
    end)
