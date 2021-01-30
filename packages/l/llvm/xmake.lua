package("llvm")

    set_kind("binary")
    set_homepage("https://llvm.org/")
    set_description("The LLVM Compiler Infrastructure")

    if is_host("macosx") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-apple-darwin.tar.xz")
            add_versions("11.0.0", "b93886ab0025cbbdbb08b46e5e403a462b0ce034811c929e96ed66c2b07fe63a")
        end
    elseif is_host("bsd") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-amd64-unknown-freebsd11.tar.xz")
            add_versions("11.0.0", "3a3bcac4da7d1ed431fef469fe52ccf9a525016d6900718a447986c7ab850d45")
        elseif os.arch() == "i386" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-i386-unknown-freebsd11.tar.xz")
            add_versions("11.0.0", "649ae62e8b85cd44b872678b118c8cbc75e2e29d94d995fddd9149fc6c3a4040")
        end
    elseif is_host("windows") then
        if os.arch() == "x86" then
            set_urls("https://github.com/xmake-mirror/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-win32.tar.xz")
            add_versions("11.0.0", "fd7f3862e6d2a7ed1855e4692702f60d0f49c04514202c8b1d6659ce1872ecb9")
        else
            set_urls("https://github.com/xmake-mirror/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-win64.tar.xz")
            add_versions("11.0.0", "de2dce781b70a66c28b389905ae825998b18b33b7b1e3e94f947a2ec57fb328d")
        end
    end

    on_install("@macosx", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
    end)

    on_test(function (package)
        os.vrun("clang --version")
    end)
