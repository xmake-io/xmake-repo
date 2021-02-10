package("llvm-mingw")

    set_kind("toolchain")
    set_homepage("https://github.com/mstorsjo/llvm-mingw")
    set_description("An LLVM/Clang/LLD based mingw-w64 toolchain")

    if is_host("windows") then
        if is_arch("x86") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-i686.zip")
            add_versions("20201020", "4f07721a81a3ba0980fc089e839d1f1a5784bbc8cee1332c15cf1b6ba24525d6")
        elseif is_arch("arm64") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-aarch64.zip")
            add_versions("20201020", "57d6e0fff94774ccd958a3d0174686189d3ec1cb5981eb4ea37fc82a007cc674")
        elseif is_arch("arm.*") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-armv7.zip")
            add_versions("20201020", "c086562124fc79e157d2cb01eacd7bd3e937d488bacdac138ee45ed6a39d3b6c")
        else
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-x86_64.zip")
            add_versions("20201020", "8f619911b61554d0394537305157f63284fab949ad0abed137b84440689fa77e")
        end
    elseif is_host("linux") then
        if linuxos.name() == "ubuntu" and linuxos.version():eq("18.04") then
            set_urls("https://github.com/mstorsjo/llvm-mingw/releases/download/$(version)/llvm-mingw-$(version)-ucrt-ubuntu-18.04.tar.xz")
            add_versions("20201020", "b41769e8c1511adb093de9f0b8bc340aa85e91f40343bbb8894cd12aca3a7543")
        end
    end

    on_install("@windows", "@linux", function (package)
        if is_host("linux") then
            assert(linuxos.name() == "ubuntu" and linuxos.version():eq("18.04"))
        end
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
