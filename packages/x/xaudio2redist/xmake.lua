package("xaudio2redist")
    set_homepage("https://www.nuget.org/packages/Microsoft.XAudio2.Redist")
    set_description("Redistributable version of XAudio 2.9 for Windows 7 SP1 or later")
    set_license("Microsoft")

    set_urls("https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/$(version)/#Microsoft.XAudio2.Redist-$(version).zip")
    add_versions("1.2.11", "4552e0b5b59de0cdbc6c217261c45f5968f7bbf1e8ab5f208e4bca6fd8fc5780")
    add_versions("1.2.10", "fe491da540331d9915cfef49493269142e60472cd7308d9fc7ff78b2a19f6380")
    add_versions("1.2.9", "a02332cb8d4096c29430be0fdb6a079e8f4a29781623ae362a811fd5dc015bb5")
    add_versions("1.2.8", "6641a1e4f12a8e47e950d805d9e030aeb765860b9a2f046c33fb13337939ff33")
    add_versions("1.2.7", "9052696dc3ab23e3b6063c6b8d41be528e10602d47eb49aeb6a87cb48df38004")
    add_versions("1.2.6", "ff3e64183760588765232f5c8e41adc361f99a3ca1f9b158ccfbe4b8eb220c2e")

    on_install("windows|x64", "windows|x86", function (package)
        os.cp("build/native/include", package:installdir())
        os.cp(path.join("build/native", package:debug() and "debug" or "release", "lib/$(arch)/*.lib"), package:installdir("lib"))
        os.cp(path.join("build/native", package:debug() and "debug" or "release", "bin/$(arch)/*.dll"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                IXAudio2* pXAudio2;
                XAudio2Create(&pXAudio2, 0, XAUDIO2_DEFAULT_PROCESSOR);
                pXAudio2->Release();
            }
        ]]}, { includes = "xaudio2.h" }))
    end)
