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

        local target
        if package:is_arch("x86_64", "x64") then
            target = "x86_64"
        elseif package:is_arch("i386", "x86", "i686") then
            target = "i686"
        elseif package:is_arch("arm64", "aarch64", "arm64-v8a") then
            target = "aarch64"
        elseif package:is_arch("armeabi-v7a", "armv7-a") then
            target = "armv7"
        elseif package:is_arch("armeabi", "armv5te") then
            target = "arm"
        elseif package:is_arch("wasm32") then
            target = "wasm32"
        elseif package:is_arch("wasm64") then
            target = "wasm64"
        end

        if target then
            if package:is_plat("windows") then
                target = target .. "-pc-windows-msvc"
            elseif package:is_plat("mingw") then
                target = target .. "-pc-windows-gnu"
            elseif package:is_plat("linux") then
                target = target .. "-unknown-linux-gnu"
            elseif package:is_plat("macosx") then
                target = target .. "-apple-darwin"
            elseif package:is_plat("android") then
                target = target .. "-linux-"
                if package:is_arch("armeabi-v7a", "armeabi", "armv7-a", "armv5te") then
                    target = target .. "androideabi"
                else
                    target = target .. "android"
                end
            elseif package:is_plat("iphoneos", "appletvos", "watchos") then
                if package:is_plat("iphoneos") then
                    target = target .. "-apple-ios"
                elseif package:is_plat("appletvos") then
                    target = target .. "-apple-tvos"
                elseif package:is_plat("watchos") then
                    target = target .. "-apple-watchos"
                end
            elseif package:is_plat("bsd") then
                target = target .. "-unknown-freebsd"
            elseif package:is_plat("wasm") then
                target = target .. "-unknown-unknown"
            end 
        end
        os.vrunv("rustup", {"target", "add", target})

        os.mv(path.join(rustup, ".rustup", "toolchains", version .. "-*", "*"), package:installdir())
        package:addenv("RC", "bin/rustc" .. (is_host("windows") and ".exe" or ""))
        package:mark_as_pathenv("RC")
    end)

    on_test(function (package)
        os.vrun("cargo --version")
        os.vrun("rustc --version")
    end)
