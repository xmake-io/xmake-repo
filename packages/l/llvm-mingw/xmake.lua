package("llvm-mingw")
    set_kind("toolchain")
    set_homepage("https://github.com/mstorsjo/llvm-mingw")
    set_description("An LLVM/Clang/LLD based mingw-w64 toolchain")

    if is_host("windows") then
        if os.arch() == "x86" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-i686.zip")
            add_versions("20201020", "4f07721a81a3ba0980fc089e839d1f1a5784bbc8cee1332c15cf1b6ba24525d6")
            add_versions("20211002", "e4faaea995c980f4b0808cc4ec17d5ea9fc2c83449f0cb3a8af07e52abe26679")
            add_versions("20220323", "34889c54195c3d677c3751fd53fa49d005e9750651f3ce994817a3c7670e7eb5")
            add_versions("20240417", "37bb76226680075f053d7925821f6ceb8b03f7a93936ec83f9a3bef5734195be")
            add_versions("20251216", "c6b17faa808f412ec8ef2086994b3fc3c16e8c7292bbaf275254d0acfa18f54d")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-aarch64.zip")
            add_versions("20201020", "57d6e0fff94774ccd958a3d0174686189d3ec1cb5981eb4ea37fc82a007cc674")
            add_versions("20211002", "1f618c4323a7e64df8a97d4fe8a933e6c8bdc131c91f90b89888927ebd179f83")
            add_versions("20220323", "f8d7d30a5eb50e9e9769d8c544644e6d25c822913e0944b21c94b75421942085")
            add_versions("20240417", "d021a71647f1f8062087a262f6b2880276b63775bedd25f3a6ca290d39505427")
            add_versions("20251216", "60c06bd255feb2ef1eb6fce7ee6b307d8f78ee6639660f49861c7c10a8a86164")
        elseif os.arch():find("arm.*") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-armv7.zip")
            add_versions("20201020", "c086562124fc79e157d2cb01eacd7bd3e937d488bacdac138ee45ed6a39d3b6c")
            add_versions("20211002", "a37c4cbd4b7c53f7c931d4ca84e1f9847315b528129310fefeafae48edd65407")
            add_versions("20220323", "1008e8eeef74194c4662bef5a2afa4691a31d894fdad8ebf2ddc27dbf6e98c86")
            add_versions("20240417", "fa6171afd4f84199af9b4546f49c6eb5280843317431f0da67d2241087991f1c")
            add_versions("20251216", "84aba9a04e23af4bbf90a742d7045f9f5ce2a233caa73e9a5e3990334e1e3109")
        else
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-x86_64.zip")
            add_versions("20201020", "8f619911b61554d0394537305157f63284fab949ad0abed137b84440689fa77e")
            add_versions("20211002", "cd0c506789eb2fd3179836e55a7dd13ceade810ec094aeec28fa5a531423e7f8")
            add_versions("20220323", "3014a95e4ec4d5c9d31f52fbd6ff43174a0d9c422c663de7f7be8c2fcc9d837a")
            add_versions("20240417", "afa69ac40f08721658bbd6826b633f3b54579d7ae4cab1f624cc6e2efd05bf0e")
            add_versions("20251216", "2d96a4b758f7f8deaec5065833fe025aa53cfc5f704d0524002510984da0ccf4")
        end
    elseif is_host("linux") then
        -- Built on Ubuntu but hopefully run on other distributions
        if os.arch() == "x86_64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-18.04-x86_64.tar.xz", {alias = "<20230320"})
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-20.04-x86_64.tar.xz", {alias = ">20230320"})

            add_versions("<20230320:20211002", "30e9400783652091d9278ce21e5c170d01a5f44e4f1a25717b63cd9ad9fbe13b")
            add_versions("<20230320:20220323", "6d69ab28a3a9a2b7159178ff11cae8545fd44c9343573900fcf60434539695d8")

            add_versions(">20230320:20240417", "d28ce4168c83093adf854485446011a0327bad9fe418014de81beba233ce76f1")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-18.04-aarch64.tar.xz", {alias = "<20230320"})
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-20.04-aarch64.tar.xz", {alias = ">20230320"})
            add_versions("<20230320:20211002", "9a26079af16713894e8a11c77e38896c4040b98daceca4408333bd1053c1a3d5")
            add_versions("<20230320:20220323", "89d4dc4515d7203b658f8257b19943a4055831a3738ed79bc179a1abcc83cde6")

            add_versions(">20230320:20240417", "c6d449ccf0a4e66bd78b341d39474318f0027bf6c5471db8cc4c8783f6c188ca")
        end
    end

    on_install("@windows", "@linux|x86_64", "@linux|arm64", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        local gcc
        if package:is_targetarch("i386", "x86", "i686") then
            gcc = "i686-w64-mingw32-gcc"
        elseif package:is_targetarch("arm64", "aarch64") then
            gcc = "aarch64-w64-mingw32-gcc"
        elseif package:is_targetarch("armv7", "arm.*") then
            gcc = "armv7-w64-mingw32-gcc"
        else
            gcc = "x86_64-w64-mingw32-gcc"
        end
        if gcc and is_host("windows") then
            gcc = gcc .. ".exe"
        end
        os.vrunv(gcc, {"--version"})
    end)
