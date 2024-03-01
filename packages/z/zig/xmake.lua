package("zig")

    set_kind("toolchain")
    set_homepage("https://www.ziglang.org/")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")

    if is_host("macosx") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-macos-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "b9b00477ec5fa1f1b89f35a7d2a58688e019910ab80a65eac2a7417162737656")
            add_versions("0.11.0", "c6ebf927bb13a707d74267474a9f553274e64906fd21bf1c75a20bde8cadf7b2")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "02483550b89d2a3070c2ed003357fd6e6a3059707b8ee3fbc0c67f83ca898437")
            add_versions("0.11.0", "1c1c6b9a906b42baae73656e24e108fd8444bb50b6e8fd03e9e7a3f8b5f05686")
        end
    elseif is_host("windows") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-windows-aarch64-$(version).zip")
            add_versions("0.10.1", "ece93b0d77b2ab03c40db99ef7ccbc63e0b6bd658af12b97898960f621305428")
            add_versions("0.11.0", "5d4bd13db5ecb0ddc749231e00f125c1d31087d708e9ff9b45c4f4e13e48c661")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_versions("0.10.1", "5768004e5e274c7969c3892e891596e51c5df2b422d798865471e05049988125")
            add_versions("0.11.0", "142caa3b804d86b4752556c9b6b039b7517a08afa3af842645c7e2dcd125f652")
        end
    elseif is_host("linux") then
        if os.arch() == "i386" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86-$(version).tar.xz")
            add_versions("0.11.0", "7b0dc3e0e070ae0e0d2240b1892af6a1f9faac3516cae24e57f7a0e7b04662a8")
        elseif os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "db0761664f5f22aa5bbd7442a1617dd696c076d5717ddefcc9d8b95278f71f5d")
            add_versions("0.11.0", "956eb095d8ba44ac6ebd27f7c9956e47d92937c103bf754745d0a39cdaa5d4c6")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "6699f0e7293081b42428f32c9d9c983854094bd15fee5489f12c4cf4518cc380")
            add_versions("0.11.0", "2d00e789fec4f71790a6e7bf83ff91d564943c5ee843c5fd966efc474b423047")
        end
    elseif is_host("freebsd") then
        if os.arch() == "x86_64" then
            set_urls("https://ziglang.org/download/$(version)/zig-freebsd-x86_64-$(version).tar.xz")
            add_versions("0.11.0", "ea430327f9178377b79264a1d492868dcff056cd76d43a6fb00719203749e958")
        end
    end

    on_install("@macosx", "@linux", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
