package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")
    set_description("Rust is a general-purpose programming language emphasizing performance, type safety, and concurrency.")

    add_versions("1.86.0", "")

    add_deps("rustup", {private = true})

    on_install("@windows|x86", "@windows|x64", "@windows|arm64", "@msys", "@cygwin", "@bsd", "@linux", "@macosx", function (package)
        local rustup = package:dep("rustup"):installdir()
        local version = package:version():shortstr()
        os.vrunv("rustup", {"install", version})
        os.mv(path.join(rustup, ".rustup", "toolchains", version .. "-*", "*"), package:installdir())
        package:addenv("RC", "bin/rustc" .. (is_host("windows") and ".exe" or ""))
        package:mark_as_pathenv("RC")
    end)

    on_test(function (package)
        os.vrun("cargo --version")
        os.vrun("rustc --version")
    end)
