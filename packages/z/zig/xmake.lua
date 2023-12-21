package("zig")

    set_kind("toolchain")
    set_homepage("https://www.ziglang.org/")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")

    if is_host("macosx") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-macos-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "b9b00477ec5fa1f1b89f35a7d2a58688e019910ab80a65eac2a7417162737656")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "02483550b89d2a3070c2ed003357fd6e6a3059707b8ee3fbc0c67f83ca898437")
        end
    elseif is_host("windows") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-windows-aarch64-$(version).zip")
            add_versions("0.10.1", "ece93b0d77b2ab03c40db99ef7ccbc63e0b6bd658af12b97898960f621305428")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_versions("0.10.1", "5768004e5e274c7969c3892e891596e51c5df2b422d798865471e05049988125")
        end
    elseif is_host("linux") then
        if os.arch() == "i386" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-i386-$(version).tar.xz")
            add_versions("0.10.1", "8c710ca5966b127b0ee3efba7310601ee57aab3dd6052a082ebc446c5efb2316")
        elseif os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "db0761664f5f22aa5bbd7442a1617dd696c076d5717ddefcc9d8b95278f71f5d")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "6699f0e7293081b42428f32c9d9c983854094bd15fee5489f12c4cf4518cc380")
        end
    end

    on_install("@macosx", "@linux", "@windows", "@msys", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
