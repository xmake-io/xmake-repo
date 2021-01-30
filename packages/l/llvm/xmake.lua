package("llvm")

    set_kind("binary")
    set_homepage("https://llvm.org/")
    set_description("The LLVM Compiler Infrastructure")

    if is_host("macosx") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-apple-darwin.tar.xz")
            add_versions("11.0.0", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
        end
    elseif is_host("linux") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-linux-gnu-ubuntu-20.04.tar.xz")
            add_versions("11.0.0", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
        elseif os.arch() == "arm64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-aarch64-linux-gnu.tar.xz")
            add_versions("11.0.0", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
        elseif os.arch() == "arm" or os.arch() == "armv7" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-armv7a-linux-gnueabihf.tar.xz")
            add_versions("11.0.0", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
        end
    elseif is_host("windows") then
        set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-11.0.0/LLVM-11.0.0-win64.exe")
    end

    on_install("macosx", "linux", "windows", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("clang --version")
    end)
