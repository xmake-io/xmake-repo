package("zig")
    set_kind("toolchain")
    set_homepage("https://ziglang.org")
    set_description("Zig is a general-purpose programming language and toolchain for maintaining robust, optimal, and reusable software.")
    set_license("MIT")

    if is_host("macosx") then
        if os.arch() == "arm64" then
            add_urls("https://ziglang.org/download/$(version)/zig-macos-aarch64-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-aarch64-macos-$(version).tar.xz")
            add_versions("0.10.1", "b9b00477ec5fa1f1b89f35a7d2a58688e019910ab80a65eac2a7417162737656")
            add_versions("0.11.0", "c6ebf927bb13a707d74267474a9f553274e64906fd21bf1c75a20bde8cadf7b2")
            add_versions("0.12.0", "294e224c14fd0822cfb15a35cf39aa14bd9967867999bf8bdfe3db7ddec2a27f")
            add_versions("0.13.0", "46fae219656545dfaf4dce12fb4e8685cec5b51d721beee9389ab4194d43394c")
            add_versions("0.14.0", "b71e4b7c4b4be9953657877f7f9e6f7ee89114c716da7c070f4a238220e95d7e")
            add_versions("0.15.1", "c4bd624d901c1268f2deb9d8eb2d86a2f8b97bafa3f118025344242da2c54d7b")
        else
            add_urls("https://ziglang.org/download/$(version)/zig-macos-x86_64-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-x86_64-macos-$(version).tar.xz")
            add_versions("0.10.1", "02483550b89d2a3070c2ed003357fd6e6a3059707b8ee3fbc0c67f83ca898437")
            add_versions("0.11.0", "1c1c6b9a906b42baae73656e24e108fd8444bb50b6e8fd03e9e7a3f8b5f05686")
            add_versions("0.12.0", "4d411bf413e7667821324da248e8589278180dbc197f4f282b7dbb599a689311")
            add_versions("0.13.0", "8b06ed1091b2269b700b3b07f8e3be3b833000841bae5aa6a09b1a8b4773effd")
            add_versions("0.14.0", "685816166f21f0b8d6fc7aa6a36e91396dcd82ca6556dfbe3e329deffc01fec3")
            add_versions("0.15.1", "9919392e0287cccc106dfbcbb46c7c1c3fa05d919567bb58d7eb16bca4116184")
        end
    elseif is_host("windows") then
        if os.arch() == "arm64" then
            add_urls("https://ziglang.org/download/$(version)/zig-windows-aarch64-$(version).zip")
            add_urls("https://ziglang.org/download/$(version)/zig-aarch64-windows-$(version).zip")
            add_versions("0.10.1", "ece93b0d77b2ab03c40db99ef7ccbc63e0b6bd658af12b97898960f621305428")
            add_versions("0.11.0", "5d4bd13db5ecb0ddc749231e00f125c1d31087d708e9ff9b45c4f4e13e48c661")
            add_versions("0.12.0", "04c6b92689241ca7a8a59b5f12d2ca2820c09d5043c3c4808b7e93e41c7bf97b")
            add_versions("0.13.0", "95ff88427af7ba2b4f312f45d2377ce7a033e5e3c620c8caaa396a9aba20efda")
            add_versions("0.14.0", "03e984383ebb8f85293557cfa9f48ee8698e7c400239570c9ff1aef3bffaf046")
            add_versions("0.15.1", "1f1bf16228b0ffcc882b713dc5e11a6db4219cb30997e13c72e8e723c2104ec6")
        else
            add_urls("https://ziglang.org/download/$(version)/zig-windows-x86_64-$(version).zip")
            add_urls("https://ziglang.org/download/$(version)/zig-x86_64-windows-$(version).zip")
            add_versions("0.10.1", "5768004e5e274c7969c3892e891596e51c5df2b422d798865471e05049988125")
            add_versions("0.11.0", "142caa3b804d86b4752556c9b6b039b7517a08afa3af842645c7e2dcd125f652")
            add_versions("0.12.0", "2199eb4c2000ddb1fba85ba78f1fcf9c1fb8b3e57658f6a627a8e513131893f5")
            add_versions("0.13.0", "d859994725ef9402381e557c60bb57497215682e355204d754ee3df75ee3c158")
            add_versions("0.14.0", "f53e5f9011ba20bbc3e0e6d0a9441b31eb227a97bac0e7d24172f1b8b27b4371")
            add_versions("0.15.1", "91e69e887ca8c943ce9a515df3af013d95a66a190a3df3f89221277ebad29e34")
        end
    elseif is_host("linux") then
        if os.arch() == "i386" then
            add_urls("https://ziglang.org/download/$(version)/zig-linux-x86-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-x86-linux-$(version).tar.xz")
            add_versions("0.11.0", "7b0dc3e0e070ae0e0d2240b1892af6a1f9faac3516cae24e57f7a0e7b04662a8")
            add_versions("0.12.0", "fb752fceb88749a80d625a6efdb23bea8208962b5150d6d14c92d20efda629a5")
            add_versions("0.13.0", "876159cc1e15efb571e61843b39a2327f8925951d48b9a7a03048c36f72180f7")
            add_versions("0.14.0", "55d1ba21de5109686ffa675b9cc1dd66930093c202995a637ce3e397816e4c08")
            add_versions("0.15.1", "dff166f25fdd06e8341d831a71211b5ba7411463a6b264bdefa8868438690b6a")
        elseif os.arch() == "arm64" then
            add_urls("https://ziglang.org/download/$(version)/zig-linux-aarch64-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-aarch64-linux-$(version).tar.xz")
            add_versions("0.10.1", "db0761664f5f22aa5bbd7442a1617dd696c076d5717ddefcc9d8b95278f71f5d")
            add_versions("0.11.0", "956eb095d8ba44ac6ebd27f7c9956e47d92937c103bf754745d0a39cdaa5d4c6")
            add_versions("0.12.0", "754f1029484079b7e0ca3b913a0a2f2a6afd5a28990cb224fe8845e72f09de63")
            add_versions("0.13.0", "041ac42323837eb5624068acd8b00cd5777dac4cf91179e8dad7a7e90dd0c556")
            add_versions("0.14.0", "ab64e3ea277f6fc5f3d723dcd95d9ce1ab282c8ed0f431b4de880d30df891e4f")
            add_versions("0.15.1", "bb4a8d2ad735e7fba764c497ddf4243cb129fece4148da3222a7046d3f1f19fe")
        else
            add_urls("https://ziglang.org/download/$(version)/zig-linux-x86_64-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-x86_64-linux-$(version).tar.xz")
            add_versions("0.10.1", "6699f0e7293081b42428f32c9d9c983854094bd15fee5489f12c4cf4518cc380")
            add_versions("0.11.0", "2d00e789fec4f71790a6e7bf83ff91d564943c5ee843c5fd966efc474b423047")
            add_versions("0.12.0", "c7ae866b8a76a568e2d5cfd31fe89cdb629bdd161fdd5018b29a4a0a17045cad")
            add_versions("0.13.0", "d45312e61ebcc48032b77bc4cf7fd6915c11fa16e4aad116b66c9468211230ea")
            add_versions("0.14.0", "473ec26806133cf4d1918caf1a410f8403a13d979726a9045b421b685031a982")
            add_versions("0.15.1", "c61c5da6edeea14ca51ecd5e4520c6f4189ef5250383db33d01848293bfafe05")
        end
    elseif is_host("bsd") then
        if os.arch() == "x86_64" then
            add_urls("https://ziglang.org/download/$(version)/zig-freebsd-x86_64-$(version).tar.xz")
            add_urls("https://ziglang.org/download/$(version)/zig-x86_64-freebsd-$(version).tar.xz")
            add_versions("0.11.0", "ea430327f9178377b79264a1d492868dcff056cd76d43a6fb00719203749e958")
            add_versions("0.13.0", "adc1ffc9be56533b2f1c7191f9e435ad55db00414ff2829d951ef63d95aaad8c")
            add_versions("0.15.1", "9714f8ac3d3dc908b1599837c6167f857c1efaa930f0cfa840699458de7c3cd0")
        end
    end

    set_policy("package.precompiled", false)

    on_install("@macosx", "@linux", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("zig version")
    end)
