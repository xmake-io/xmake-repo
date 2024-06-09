package("zig")

    set_kind("toolchain")
    set_homepage("https://www.ziglang.org/")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")

    if is_host("macosx") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-macos-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "b9b00477ec5fa1f1b89f35a7d2a58688e019910ab80a65eac2a7417162737656")
            add_versions("0.11.0", "c6ebf927bb13a707d74267474a9f553274e64906fd21bf1c75a20bde8cadf7b2")
            add_versions("0.12.0", "294e224c14fd0822cfb15a35cf39aa14bd9967867999bf8bdfe3db7ddec2a27f")
            add_versions("0.13.0", "46fae219656545dfaf4dce12fb4e8685cec5b51d721beee9389ab4194d43394c")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "02483550b89d2a3070c2ed003357fd6e6a3059707b8ee3fbc0c67f83ca898437")
            add_versions("0.11.0", "1c1c6b9a906b42baae73656e24e108fd8444bb50b6e8fd03e9e7a3f8b5f05686")
            add_versions("0.12.0", "4d411bf413e7667821324da248e8589278180dbc197f4f282b7dbb599a689311")
            add_versions("0.13.0", "8b06ed1091b2269b700b3b07f8e3be3b833000841bae5aa6a09b1a8b4773effd")    
        end
    elseif is_host("windows") then
        if os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-windows-aarch64-$(version).zip")
            add_versions("0.10.1", "ece93b0d77b2ab03c40db99ef7ccbc63e0b6bd658af12b97898960f621305428")
            add_versions("0.11.0", "5d4bd13db5ecb0ddc749231e00f125c1d31087d708e9ff9b45c4f4e13e48c661")
            add_versions("0.12.0", "04c6b92689241ca7a8a59b5f12d2ca2820c09d5043c3c4808b7e93e41c7bf97b")
            add_versions("0.13.0", "95ff88427af7ba2b4f312f45d2377ce7a033e5e3c620c8caaa396a9aba20efda")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_versions("0.10.1", "5768004e5e274c7969c3892e891596e51c5df2b422d798865471e05049988125")
            add_versions("0.11.0", "142caa3b804d86b4752556c9b6b039b7517a08afa3af842645c7e2dcd125f652")
            add_versions("0.12.0", "2199eb4c2000ddb1fba85ba78f1fcf9c1fb8b3e57658f6a627a8e513131893f5")
            add_versions("0.13.0", "d859994725ef9402381e557c60bb57497215682e355204d754ee3df75ee3c158")
        end
    elseif is_host("linux") then
        if os.arch() == "i386" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86-$(version).tar.xz")
            add_versions("0.11.0", "7b0dc3e0e070ae0e0d2240b1892af6a1f9faac3516cae24e57f7a0e7b04662a8")
            add_versions("0.12.0", "fb752fceb88749a80d625a6efdb23bea8208962b5150d6d14c92d20efda629a5")
            add_versions("0.13.0", "876159cc1e15efb571e61843b39a2327f8925951d48b9a7a03048c36f72180f7")
        elseif os.arch() == "arm64" then
            set_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_versions("0.10.1", "db0761664f5f22aa5bbd7442a1617dd696c076d5717ddefcc9d8b95278f71f5d")
            add_versions("0.11.0", "956eb095d8ba44ac6ebd27f7c9956e47d92937c103bf754745d0a39cdaa5d4c6")
            add_versions("0.12.0", "754f1029484079b7e0ca3b913a0a2f2a6afd5a28990cb224fe8845e72f09de63")
            add_versions("0.13.0", "041ac42323837eb5624068acd8b00cd5777dac4cf91179e8dad7a7e90dd0c556")
        else
            set_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_versions("0.10.1", "6699f0e7293081b42428f32c9d9c983854094bd15fee5489f12c4cf4518cc380")
            add_versions("0.11.0", "2d00e789fec4f71790a6e7bf83ff91d564943c5ee843c5fd966efc474b423047")
            add_versions("0.12.0", "c7ae866b8a76a568e2d5cfd31fe89cdb629bdd161fdd5018b29a4a0a17045cad")
            add_versions("0.13.0", "d45312e61ebcc48032b77bc4cf7fd6915c11fa16e4aad116b66c9468211230ea")
        end
    elseif is_host("bsd") then
        if os.arch() == "x86_64" then
            set_urls("https://ziglang.org/download/$(version)/zig-freebsd-x86_64-$(version).tar.xz")
            add_versions("0.11.0", "ea430327f9178377b79264a1d492868dcff056cd76d43a6fb00719203749e958")
            add_versions("0.13.0", "adc1ffc9be56533b2f1c7191f9e435ad55db00414ff2829d951ef63d95aaad8c")
        end
    end

    on_install("@macosx", "@linux", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
