package("cmake")
    set_kind("binary")
    set_homepage("https://cmake.org")
    set_description("A cross-platform family of tool designed to build, test and package software")

    if is_host("macosx") then
        add_urls("https://cmake.org/files/v$(version).tar.gz", {version = function (version)
                return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. (version:ge("3.20") and "-macos-universal" or "-Darwin-x86_64")
            end})
        add_urls("https://github.com/Kitware/CMake/releases/download/v$(version).tar.gz", {version = function (version)
                return version .. "/cmake-" .. version .. (version:ge("3.20") and "-macos-universal" or "-Darwin-x86_64")
            end})
        add_versions("3.11.4", "2b5eb705f036b1906a5e0bce996e9cd56d43d73bdee8318ece3e5ce31657b812")
        add_versions("3.15.4", "adfbf611d21daa83b9bf6d85ab06a455e481b63a38d6e1270d563b03d4e5f829")
        add_versions("3.18.4", "9d27049660474cf134ab46fa0e0db771b263313fcb8ba82ee8b2d1a1a62f8f20")
        add_versions("3.21.0", "c1c6f19dfc9c658a48b5aed22806595b2337bb3aedb71ab826552f74f568719f")
        add_versions("3.22.1", "9ba46ce69d524f5bcdf98076a6b01f727604fb31cf9005ec03dea1cf16da9514")
        add_versions("3.24.1", "71bb8db69826d74c395a3c3bbf8b773dbe9f54a2c7331266ba70da303e9c97a1")
        add_versions("3.24.2", "efb11a78c064dd7c54a50b8da247254d252112c402c6e48cb7db3f9c84a4e5ad")
        add_versions("3.26.4", "5417fb979c1f82aaffe4420112e2c84562c024b6683161afb520c9e378161340")
        add_versions("3.28.1", "0e0942bb5ed7ee1aeda0c00b3cb7738f2590865f1d69fe1d5212cbc26fc040a5")
        add_versions("3.28.3", "d9e2c22fec920a4d1f6b0d0683c035d799475c179c91e41e1a7fbfab610a0305")
        add_versions("3.29.2", "0d670b59dddd064d24cf8c386abf3590bda2642bb169e11534cf1e3d1ae3a76a")
        add_versions("3.30.1", "51e12618829b811bba6f033ee8f39f6192da1b6abb20d82a7899d5134e879a4c")
        add_versions("3.30.2", "c6fdda745f9ce69bca048e91955c7d043ba905d6388a62e0ff52b681ac17183c")
        add_versions("4.0.0", "a7d66b55c673845e21b5541340417bae4823958393a59f4b644c26d433b19a0b")
    elseif is_host("linux") then
        if os.arch():find("arm64.*") then
            add_urls("https://cmake.org/files/v$(version)-aarch64.tar.gz", {version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. (version:ge("3.20") and "-linux" or "-Linux")
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)-aarch64.tar.gz", {version = function (version)
                return version .. "/cmake-" .. version .. (version:ge("3.20") and "-linux" or "-Linux")
                end})
            add_versions("3.24.2", "5f1c0d49bac89915b5c68811c2430e5de6c8e606785b9f2919eabee86c2f12b4")
            add_versions("3.26.4", "1c9843c92f40bee1a16baa12871693d3e190c9a222259a89e406d4d9aae6cf74")
            add_versions("3.28.1", "e84d88e46ed8c85fbe259bcd4ca07df7a928df87e84013e0da34d91b01a25d71")
            add_versions("3.28.3", "bbf023139f944cefe731d944f2864d8ea3ea0c4f9310b46ac72b3cb4e314b023")
            add_versions("3.29.2", "ca883c6dc3ce9eebd833804f0f940ecbbff603520cfd169ee58916dbbc23c2b8")
            add_versions("3.30.1", "ad234996f8750f11d7bd0d17b03f55c434816adf1f1671aab9e8bab21a43286a")
            add_versions("3.30.2", "d18f50f01b001303d21f53c6c16ff12ee3aa45df5da1899c2fe95be7426aa026")
            add_versions("4.0.0", "3727d7a6ca900331447a55c08404cc11248b2e8d2709a6b3ed85b01189bb16af")
        else
            add_urls("https://cmake.org/files/v$(version)-x86_64.tar.gz", {version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. (version:ge("3.20") and "-linux" or "-Linux")
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)-x86_64.tar.gz", {version = function (version)
                return version .. "/cmake-" .. version .. (version:ge("3.20") and "-linux" or "-Linux")
                end})
            add_versions("3.11.4", "6dab016a6b82082b8bcd0f4d1e53418d6372015dd983d29367b9153f1a376435")
            add_versions("3.15.4", "7c2b17a9be605f523d71b99cc2e5b55b009d82cf9577efb50d4b23056dee1109")
            add_versions("3.18.4", "149e0cee002e59e0bb84543cf3cb099f108c08390392605e944daeb6594cbc29")
            add_versions("3.21.0", "d54ef6909f519740bc85cec07ff54574cd1e061f9f17357d9ace69f61c6291ce")
            add_versions("3.22.1", "73565c72355c6652e9db149249af36bcab44d9d478c5546fd926e69ad6b43640")
            add_versions("3.24.1", "827bf068cfaa23a9fb95f990c9f8a7ed8f2caeb3af62b5c0a2fed7a8dd6dde3e")
            add_versions("3.24.2", "71a776b6a08135092b5beb00a603b60ca39f8231c01a0356e205e0b4631747d9")
            add_versions("3.26.4", "ba1e0dcc710e2f92be6263f9617510b3660fa9dc409ad2fb8190299563f952a0")
            add_versions("3.28.1", "f76398c24362ad87bad1a3d6f1e8f4377632b5b1c360c4ba1fd7cd205fd9d8d4")
            add_versions("3.28.3", "804d231460ab3c8b556a42d2660af4ac7a0e21c98a7f8ee3318a74b4a9a187a6")
            add_versions("3.29.2", "0416c70cf88e8f92efcbfe292e181bc09ead7d70e29ab37b697522c01121eab5")
            add_versions("3.30.1", "ac31f077ef3378641fa25a3cb980d21b2f083982d3149a8f2eb9154f2b53696b")
            add_versions("3.30.2", "cdd7fb352605cee3ae53b0e18b5929b642900e33d6b0173e19f6d4f2067ebf16")
            add_versions("4.0.0", "a06e6e32da747e569162bc0442a3fd400fadd9db7d4f185c9e4464ab299a294b")
        end
    elseif is_host("windows") then
        if os.arch() == "x64" then
            add_urls("https://cmake.org/files/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. (version:ge("3.20") and "-windows-x86_64" or "-win64-x64")
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return version .. "/cmake-" .. version .. (version:ge("3.20") and "-windows-x86_64" or "-win64-x64")
                end})
            add_versions("3.11.4", "d3102abd0ded446c898252b58857871ee170312d8e7fd5cbff01fbcb1068a6e5")
            add_versions("3.15.4", "5bb49c0274800c38833e515a01af75a7341db68ea82c71856bb3cf171d2068be")
            add_versions("3.18.4", "a932bc0c8ee79f1003204466c525b38a840424d4ae29f9e5fb88959116f2407d")
            add_versions("3.21.0", "c7b88c907a753f4ec86e43ddc89f91f70bf1b011859142f7f29e6d51ea4abb3c")
            add_versions("3.22.1", "35fbbb7d9ffa491834bbc79cdfefc6c360088a3c9bf55c29d111a5afa04cdca3")
            add_versions("3.24.1", "c1b17431a16337d517f7ba78c7067b6f143a12686cb8087f3dd32f3fa45f5aae")
            add_versions("3.24.2", "6af30354eecbb7113b0f0142d13c03d21abbc9f4dbdcddaf88df1f9ca1bc4d6f")
            add_versions("3.26.4", "62c35427104a4f8205226f72708d71334bd36a72cf72c60d0e3a766d71dcc78a")
            add_versions("3.28.1", "671332249bc7cc7424523d6c2b5edd3e3de90a43b8b82e8782f42da4fe4c562d")
            add_versions("3.28.3", "cac7916f7e1e73a25de857704c94fd5b72ba9fe2f055356b5602d2f960e50e5b")
            add_versions("3.29.2", "86b5de51f60a0e9d62be4d8ca76ea467d154083d356fcc9af1409606be341cd8")
            add_versions("3.30.1", "cf7788ff9d92812da194847d4ec874fc576f34079987d0f20c96cd09e2a16220")
            add_versions("3.30.2", "48bf4b3dc2d668c578e0884cac7878e146b036ca6b5ce4f8b5572f861b004c25")
            add_versions("4.0.0", "89e87f3e297b70f1349ee7c5f90783ca96efb986b70c558c799c3c9b1b716456")
        elseif os.arch() == "x86" then
            add_urls("https://cmake.org/files/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. (version:ge("3.20") and "-windows-i386" or "-win32-x86")
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return version .. "/cmake-" .. version .. (version:ge("3.20") and "-windows-i386" or "-win32-x86")
                end})
            add_versions("3.11.4", "b068001ff879f86e704977c50a8c5917e4b4406c66242366dba2674abe316579")
            add_versions("3.15.4", "19c2bfd26c4de4d8046dd5ad6de95b57a2556559ec81b13b94e63ea4ae49b3f2")
            add_versions("3.18.4", "4c519051853686927f87df99669ada3ff15a3086535a7131892febd7c6e2f122")
            add_versions("3.21.0", "11ee86b7f9799724fc16664c63e308bfe3fbc22c9df8ef4955ad4b248f3e680b")
            add_versions("3.22.1", "f53494e3b35e5a1177ad55c28763eb5bb45772c1d80778c0f96c45ce4376b6e8")
            add_versions("3.24.1", "a0b894e2a814d2353f1e581eb6ca3c878a39c071624495729dbcf9978e1579f2")
            add_versions("3.24.2", "52f174dc7f52a9c496c7a49ee35456466c07c8ce29aa2092f4b4536ce5d7ed57")
            add_versions("3.26.4", "342ca44f494985f8ef43676eb8a0404b2c68321036e28aa221ceab51d377b158")
            add_versions("3.28.1", "e9591cfdb1d394eee84acdecf880cbd91cf0707dfd0d58bf3796b88475f46cb9")
            add_versions("3.28.3", "411812b6b29ac793faf69bdbd36c612f72659363c5491b9f0a478915db3fc58c")
            add_versions("3.29.2", "e51b281c9dfd1498834729b33bf49fc668ad1dadbc2eaba7b693d0f7d748450d")
            add_versions("3.30.1", "f5fb1d93b82e9a5fbd5853d4b17a130605f0b4ed13a655d1371c2d6d55f9261d")
            add_versions("3.30.2", "d01f7ea52097dd58aa225884b1ecc543827e9ef99d36dac2898609a0d5e60eb6")
            add_versions("4.0.0", "28408c0ca3b4461550bbcad94c526846699ed79366d81b57db0375cb119875dd")
        elseif os.arch() == "arm64" then
            add_urls("https://cmake.org/files/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/cmake-" .. version .. "-windows-arm64"
                end})
            add_urls("https://github.com/Kitware/CMake/releases/download/v$(version).zip", {excludes = {"*/doc/*"}, version = function (version)
                    return version .. "/cmake-" .. version .. "-windows-arm64"
                end})
            add_versions("3.28.1", "a839b8d32c11b24f078142b5b8c3361a955ebc65788f0f0353b2121fe2f74e49")
            add_versions("3.28.3", "cfe023b7e82812ef802fb1ec619f6cfa2fdcb58ee61165fc315086286fe9cdcc")
            add_versions("3.29.2", "5b16a0db4966c04582c40131038de49d5b0161fcd950dc9e955753dfab858882")
            add_versions("3.30.1", "02b433f70aa549449be2d53046d0179590bf3b6290d9fda3fbbb23f96a4f2802")
            add_versions("3.30.2", "c0cef52e8f60eb1c3058f8bc0b3803c27d79f066b7d7d94f46a2c689bbd36f22")
            add_versions("4.0.0", "6a24f1ea0965a10a2508b16db1ec8b62c83d5323ac33a1aa7d201797ba147302")
        end
    else
        add_urls("https://github.com/Kitware/CMake/releases/download/v$(version)/cmake-$(version).tar.gz")
        add_versions("3.18.4", "597c61358e6a92ecbfad42a9b5321ddd801fc7e7eca08441307c9138382d4f77")
        add_versions("3.21.0", "4a42d56449a51f4d3809ab4d3b61fd4a96a469e56266e896ce1009b5768bd2ab")
        add_versions("3.22.1", "0e998229549d7b3f368703d20e248e7ee1f853910d42704aa87918c213ea82c0")
        add_versions("3.24.1", "4931e277a4db1a805f13baa7013a7757a0cbfe5b7932882925c7061d9d1fa82b")
        add_versions("3.24.2", "0d9020f06f3ddf17fb537dc228e1a56c927ee506b486f55fe2dc19f69bf0c8db")
        add_versions("3.26.4", "313b6880c291bd4fe31c0aa51d6e62659282a521e695f30d5cc0d25abbd5c208")
        add_versions("3.28.1", "15e94f83e647f7d620a140a7a5da76349fc47a1bfed66d0f5cdee8e7344079ad")
        add_versions("3.28.3", "72b7570e5c8593de6ac4ab433b73eab18c5fb328880460c86ce32608141ad5c1")
        add_versions("3.29.2", "36db4b6926aab741ba6e4b2ea2d99c9193222132308b4dc824d4123cb730352e")
        add_versions("3.30.1", "df9b3c53e3ce84c3c1b7c253e5ceff7d8d1f084ff0673d048f260e04ccb346e1")
        add_versions("3.30.2", "46074c781eccebc433e98f0bbfa265ca3fd4381f245ca3b140e7711531d60db2")
        add_versions("4.0.0", "ddc54ad63b87e153cf50be450a6580f1b17b4881de8941da963ff56991a4083b")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::cmake")
    elseif is_plat("linux") then
        add_extsources("pacman::cmake", "apt::cmake")
    elseif is_plat("macosx") then
        add_extsources("brew::cmake")
    end

    on_load(function (package)
        -- xmake v3.x will enable this ninja policy by default
        import("core.project.project")
        if xmake.version():ge("2.9.0") and project.policy("package.cmake_generator.ninja") then
            -- We mark it as public, even if cmake is already installed,
            -- we need also to install ninja and export the ninja PATH. (above xmake 2.9.8)
            package:add("deps", "ninja", {public = true})
        end
    end)

    on_install("@macosx", function (package)
        os.cp("CMake.app/Contents/bin", package:installdir())
        os.cp("CMake.app/Contents/share", package:installdir())
    end)

    on_install("@linux", "@windows", "@msys", "@cygwin", function (package)
        os.cp("bin", package:installdir())
        os.cp("share", package:installdir())
    end)

    on_install("@bsd", function (package)
        import("core.base.option")
        os.vrunv("sh", {"./bootstrap", "--parallel=" .. (option.get("jobs") or tostring(os.default_njob())), "--prefix=" .. package:installdir()})
        import("package.tools.make").install(package)
    end)

    on_test(function (package)
        os.vrun("cmake --version")
    end)
