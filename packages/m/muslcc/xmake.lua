package("muslcc")

    set_kind("toolchain")
    set_homepage("https://musl.cc/")
    set_description("static cross- and native- musl-based toolchains.")

    if is_host("windows") then
        if is_arch("arm64") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/aarch64-linux-musl-cross.win.zip")
            add_versions("20210202", "1fa7226fb2317fa8dd1571f2a8964e8e4bb973479ec18e35e04b6b0606ff2eba")
        elseif is_arch("arm.*") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/arm-linux-musleabi-cross.win.zip")
            add_versions("20210202", "87061cdc288b6a74b3414bb70ce91da524c126199548cf4b86ae40e074988291")
        elseif is_arch("x86", "i386") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/i686-linux-musl-cross.win.zip")
            add_versions("20210202", "5f2903646a4bdd45d6dadfa65652a3bfe4191eab2e5b0ae1dd9b2e6ccf87f629")
        else
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/x86_64-linux-musl-cross.win.zip")
            add_versions("20210202", "3a13f8bb3694b26ffbe3fe97d45db6cabadb662161cd5fc9cc80fc0adfb02091")
        end
    elseif is_host("linux") then
        if is_arch("arm64") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/aarch64-linux-musl-cross.linux.tgz")
            add_versions("20210202", "7e237ecd528d31cb3eadc48a95f4779467f588a89444c43276c77cdfe93787de")
        elseif is_arch("arm.*") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/arm-linux-musleabi-cross.linux.tgz")
            add_versions("20210202", "4e03e69f30eacf6bb573999b5a20c59e320720ed02edccfebfa6f89a9e76b445")
        elseif is_arch("x86", "i386") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/i686-linux-musl-cross.linux.tgz")
            add_versions("20210202", "411e98b50c2f965ec0c7d752896151dc2068060e583f0eb245f2c86556d749c3")
        else
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/x86_64-linux-musl-cross.linux.tgz")
            add_versions("20210202", "37ef7b69d4c4a20bb2c5e7e01ec7c60c1ac7de2c33b029eaa6c0d8b9e1869c6b")
        end
    elseif is_host("macosx") then
        if is_arch("arm64") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/aarch64-linux-musl-cross.mac.tgz")
            add_versions("20210202", "5b3e91ebc430428578fa2a443256aca866e61da886d5f645eee9725485877389")
        elseif is_arch("arm.*") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/arm-linux-musleabi-cross.mac.tgz")
            add_versions("20210202", "a177df3f847181c0c7f2b34b9bd7725b4c556c11a347aa0ae36e09ebf23fb480")
        elseif is_arch("x86", "i386") then
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/i686-linux-musl-cross.mac.tgz")
            add_versions("20210202", "12cd8be154c122f6957ce21a9a5ff2d55a8bd660707b17fb3248578ac955ba25")
        else
            set_urls("https://github.com/xmake-mirror/musl.cc/releases/download/$(version)/x86_64-linux-musl-cross.mac.tgz")
            add_versions("20210202", "09e63d9ec8d2e21643750b9543fb138e59c8e255e5a0ae86bc099368addead89")
        end
    end

    if is_host("macosx") then
        -- fix missing libisl.22.dylib
        add_deps("libisl 0.22", {host = true, configs = {shared = true}})
    end

    on_check(function (package)
        local arch = os.arch()
        assert(arch == "x86_64" or arch == "i386" or arch == "x86" or arch == "x64", "package(%s): only run on x86/x86_64 machine.", package:name())
    end)

    on_install("@windows", "@msys", "@linux", "@macosx", function (package)
        -- remove soft link
        os.tryrm("usr")
        -- remove invalid path, it will break copy directory
        -- arm-linux-musleabi/lib/ld-musl-arm.so.1 -> /lib/libc.so
        os.tryrm("arm-linux-musleabi/lib/ld-musl-arm.so.1")
        -- fix missing libisl.22.dylib
        if is_host("macosx") then
            local function patchbin(bin_name)
                local cross
                if package:is_targetarch("arm64") then
                    cross = "aarch64-linux-musl-"
                elseif package:is_targetarch("arm.*") then
                    cross = "arm-linux-musleabi-"
                elseif package:is_targetarch("x86", "i386") then
                    cross = "i686-linux-musl-"
                else
                    cross = "x86_64-linux-musl-"
                end
                local binfile = path.join("bin", cross .. bin_name)
                local binfile_raw = binfile .. "-raw"
                os.mv(binfile, binfile_raw)
                io.writefile(binfile, ([[
#!/usr/bin/env bash
export DYLD_LIBRARY_PATH="%s"
"%s" "$@"]]):format(package:dep("libisl"):installdir("lib"),
                    path.join(package:installdir(), binfile_raw)))
                os.vrunv("chmod", {"777", binfile})
            end
            patchbin("gcc")
            patchbin("g++")
        end
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc
        if package:is_targetarch("arm64") then
            gcc = "aarch64-linux-musl-gcc"
        elseif package:is_targetarch("arm.*") then
            gcc = "arm-linux-musleabi-gcc"
        elseif package:is_targetarch("x86", "i386") then
            gcc = "i686-linux-musl-gcc"
        else
            gcc = "x86_64-linux-musl-gcc"
        end
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        local file = os.tmpfile() .. ".c"
        io.writefile(file, "int main(int argc, char** argv) {return 0;}")
        os.vrunv(gcc, {"-c", file})
    end)
