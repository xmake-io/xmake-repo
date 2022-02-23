package("llvm-mingw")

    set_kind("toolchain")
    set_homepage("https://github.com/mstorsjo/llvm-mingw")
    set_description("An LLVM/Clang/LLD based mingw-w64 toolchain")

    if is_host("windows") then
        if os.arch() == "x86" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-i686.zip")
            add_versions("20201020", "4f07721a81a3ba0980fc089e839d1f1a5784bbc8cee1332c15cf1b6ba24525d6")
            add_versions("20211002", "e4faaea995c980f4b0808cc4ec17d5ea9fc2c83449f0cb3a8af07e52abe26679")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-aarch64.zip")
            add_versions("20201020", "57d6e0fff94774ccd958a3d0174686189d3ec1cb5981eb4ea37fc82a007cc674")
            add_versions("20211002", "1f618c4323a7e64df8a97d4fe8a933e6c8bdc131c91f90b89888927ebd179f83  ")
        elseif os.arch():find("arm.*") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-armv7.zip")
            add_versions("20201020", "c086562124fc79e157d2cb01eacd7bd3e937d488bacdac138ee45ed6a39d3b6c")
            add_versions("20211002", "a37c4cbd4b7c53f7c931d4ca84e1f9847315b528129310fefeafae48edd65407")
        else
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-x86_64.zip")
            add_versions("20201020", "8f619911b61554d0394537305157f63284fab949ad0abed137b84440689fa77e")
            add_versions("20211002", "cd0c506789eb2fd3179836e55a7dd13ceade810ec094aeec28fa5a531423e7f8")
        end
    elseif is_host("linux") then
        -- Built on Ubuntu but hopefully run on other distributions
        if os.arch() == "x86_64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-18.04-x86_64.tar.xz")
            add_versions("20211002", "30e9400783652091d9278ce21e5c170d01a5f44e4f1a25717b63cd9ad9fbe13b")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-18.04-aarch64.tar.xz")
            add_versions("20211002", "9a26079af16713894e8a11c77e38896c4040b98daceca4408333bd1053c1a3d5")
        end
    end

    on_install("@windows", "@linux|x86_64,arm64", function (package)
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
