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
    elseif is_host("linux") then
        set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).tar.xz")
        add_versions("11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
    end

    if is_host("linux") then
        add_deps("libffi", {host = true})
        add_deps("binutils", {host = true}) -- needed for gold and strip
        --add_deps("libelf", {host  = true}) -- openmp requires <gelf.h>

        --[[
        add_patches("11.0.0", "https://github.com/llvm/llvm-project/commit/c86f56e32e724c6018e579bb2bc11e667c96fc96.patch?full_index=1", "6e13e01b4f9037bb6f43f96cb752d23b367fe7db4b66d9bf2a4aeab9234b740a")
        add_patches("11.0.0", "https://github.com/llvm/llvm-project/commit/31e5f7120bdd2f76337686d9d169b1c00e6ee69c.patch?full_index=1", "f025110aa6bf80bd46d64a0e2b1e2064d165353cd7893bef570b6afba7e90b4d")
        add_patches("11.0.0", "https://github.com/llvm/llvm-project/commit/3c7bfbd6831b2144229734892182d403e46d7baf.patch?full_index=1", "62014ddad6d5c485ecedafe3277fe7978f3f61c940976e3e642536726abaeb68")
        add_patches("11.0.0", "https://github.com/llvm/llvm-project/commit/c4d7536136b331bada079b2afbb2bd09ad8296bf.patch?full_index=1", "2b894cbaf990510969bf149697882c86a068a1d704e749afa5d7b71b6ee2eb9f")
        ]]
    end

    on_install("@macosx", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("@linux", function (package)
        local projects = {
            "clang",
            --"clang-tools-extra",
            --"lld",
            --"lldb",
            --"openmp",
            --"polly",
            --"mlir",
        }
        local runtimes = {
            "compiler-rt",
            "libunwind",
            "libcxxabi"
        }
        local configs = {
            "-DCMAKE_BUILD_TYPE=Release",
            "-DLLVM_ENABLE_PROJECTS=" .. table.concat(projects, ";"),
            "-DLLVM_ENABLE_RUNTIMES=" .. table.concat(runtimes, ";"),
            "-DLLVM_POLLY_LINK_INTO_TOOLS=ON",
            "-DLLVM_BUILD_EXTERNAL_COMPILER_RT=ON",
            "-DLLVM_LINK_LLVM_DYLIB=ON",
            "-DLLVM_ENABLE_EH=ON",
            "-DLLVM_ENABLE_FFI=ON",
            "-DLLVM_ENABLE_RTTI=ON",
            "-DLLVM_INCLUDE_DOCS=OFF",
            "-DLLVM_INCLUDE_TESTS=OFF",
            "-DLLVM_INSTALL_UTILS=ON",
            "-DLLVM_ENABLE_Z3_SOLVER=OFF",
            "-DLLVM_OPTIMIZED_TABLEGEN=ON",
            "-DLLVM_TARGETS_TO_BUILD=all",
            "-DFFI_INCLUDE_DIR=" .. package:dep("libffi"):installdir("include"),
            "-DFFI_LIBRARY_DIR=" .. package:dep("libffi"):installdir("lib"),
            "-DLLDB_USE_SYSTEM_DEBUGSERVER=ON",
            "-DLLDB_ENABLE_PYTHON=OFF",
            "-DLLDB_ENABLE_LUA=OFF",
            "-DLLDB_ENABLE_LZMA=OFF",
            "-DLIBOMP_INSTALL_ALIASES=OFF",
            "-DCLANG_PYTHON_BINDINGS_VERSIONS=#{py_ver}"
        }
        if package:is_plat("macosx") then
            table.insert(configs, "-DLLVM_BUILD_LLVM_C_DYLIB=ON")
            table.insert(configs, "-DLLVM_ENABLE_LIBCXX=ON")
            table.insert(configs, "-DLLVM_CREATE_XCODE_TOOLCHAIN=ON") -- TODO
        else
            table.insert(configs, "-DLLVM_BUILD_LLVM_C_DYLIB=OFF")
            table.insert(configs, "-DLLVM_ENABLE_LIBCXX=OFF")
            table.insert(configs, "-DLLVM_CREATE_XCODE_TOOLCHAIN=OFF")
            table.insert(configs, "-DCLANG_DEFAULT_CXX_STDLIB=libstdc++")
            -- enable llvm gold plugin for LTO
            table.insert(configs, "-DLLVM_BINUTILS_INCDIR=" .. package:dep("binutils"):installdir("include"))
        end
        os.cd("llvm")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("clang --version")
    end)
