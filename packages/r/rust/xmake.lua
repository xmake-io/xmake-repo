package("rust")
    set_kind("toolchain")
    set_homepage("https://rust-lang.org")
    set_description("Rust is a general-purpose programming language emphasizing performance, type safety, and concurrency.")

    add_versions("1.86.0", "")

    add_deps("ca-certificates", {host = true, private = true})
    add_deps("rustup", {host = true, private = true, system = false})

    on_install(function (package)
        local rustup = assert(os.getenv("RUSTUP_HOME"), "cannot find rustup home!")
        local version = package:version():shortstr()

        os.vrunv("rustup", {"install", "--no-self-update", version})

        local target
        if package:is_targetarch("x86_64", "x64") then
            target = "x86_64"
        elseif package:is_targetarch("i386", "x86", "i686") then
            target = "i686"
        elseif package:is_targetarch("arm64", "aarch64", "arm64-v8a") then
            target = "aarch64"
        elseif package:is_targetarch("armeabi-v7a", "armv7-a") then
            target = "armv7"
        elseif package:is_targetarch("armeabi", "armv5te") then
            target = "arm"
        elseif package:is_targetarch("wasm32") then
            target = "wasm32"
        elseif package:is_targetarch("wasm64") then
            target = "wasm64"
        end

        if target then
            if is_plat("windows") then
                target = target .. "-pc-windows-msvc"
            elseif is_plat("mingw") then
                target = target .. "-pc-windows-gnu"
            elseif is_plat("linux") then
                target = target .. "-unknown-linux-gnu"
            elseif is_plat("macosx") then
                target = target .. "-apple-darwin"
            elseif is_plat("android") then
                target = target .. "-linux-"
                if package:is_targetarch("armeabi-v7a", "armeabi", "armv7-a", "armv5te") then
                    target = target .. "androideabi"
                else
                    target = target .. "android"
                end
            elseif is_plat("iphoneos", "appletvos", "watchos") then
                if is_plat("iphoneos") then
                    target = target .. "-apple-ios"
                elseif is_plat("appletvos") then
                    target = target .. "-apple-tvos"
                elseif is_plat("watchos") then
                    target = target .. "-apple-watchos"
                end
            elseif is_plat("bsd") then
                target = target .. "-unknown-freebsd"
            elseif is_plat("wasm") then
                target = target .. "-unknown-unknown"
            end
            os.vrunv("rustup", {"target", "add", target})
        end

        os.mv(path.join(rustup, "toolchains", version .. "-*", "*"), package:installdir())

        -- cleanup to prevent rustup to think the toolchain is still installed
        os.rm(path.join(rustup, "toolchains"))
        os.rm(path.join(rustup, "update-hashes"))

        package:addenv("RC", "bin/rustc" .. (is_host("windows") and ".exe" or ""))
        package:mark_as_pathenv("RC")
    end)

    on_test(function (package)
        os.vrun("cargo --version")
        os.vrun("rustc --version")
    end)
