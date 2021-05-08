package("llvm")

    set_kind("toolchain")
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
        if linuxos.name() == "ubuntu" and linuxos.version():eq("20.04") and os.arch() == "x86_64" then
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-linux-gnu-ubuntu-20.04.tar.xz")
            add_versions("11.0.0", "829f5fb0ebda1d8716464394f97d5475d465ddc7bea2879c0601316b611ff6db")
        else
            set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).tar.xz")
            add_versions("11.0.0", "b7b639fc675fa1c86dd6d0bc32267be9eb34451748d2efd03f674b773000e92b")
        end
    end

    add_configs("clang",                    {description = "Enable clang project.", default = true, type = "boolean"})
    add_configs("clang-tools-extra",        {description = "Enable extra clang tools project.", default = false, type = "boolean"})
    add_configs("lld",                      {description = "Enable lld project.", default = false, type = "boolean"})
    add_configs("lldb",                     {description = "Enable lldb project.", default = false, type = "boolean"})
    add_configs("openmp",                   {description = "Enable openmp project.", default = false, type = "boolean"})
    add_configs("polly",                    {description = "Enable polly project.", default = false, type = "boolean"})
    add_configs("mlir",                     {description = "Enable mlir project.", default = false, type = "boolean"})

    add_configs("compiler-rt",              {description = "Enable compiler-rt runtime.", default = true, type = "boolean"})
    add_configs("libunwind",                {description = "Enable libunwind runtime.", default = true, type = "boolean"})
    add_configs("libcxxabi",                {description = "Enable clang runtime.", default = true, type = "boolean"})

    if is_host("linux") then
        if linuxos.name() == "ubuntu" and linuxos.version():eq("20.04") and os.arch() == "x86_64" then
            -- use binary directly
        else
            add_deps("cmake")
            add_deps("libffi", {host = true})
            add_deps("binutils", {host = true}) -- needed for gold and strip
        end
    end

    on_load("@linux", function (package)
        if linuxos.name() == "ubuntu" and linuxos.version():eq("20.04") and os.arch() == "x86_64" then
            return
        elseif package:config("openmp") then
            package:add("deps", "libelf", {host = true})
        end
    end)

    if on_fetch then
        on_fetch(function (package, opt)
            if opt.system then
                local version = try {function() return os.iorunv("llvm-config --version") end}
                if version then
                    return {version = version:trim()}
                end
            end
        end)
    end

    on_install("@macosx", "@windows", "@msys", "@bsd", function (package)
        os.cp("*", package:installdir())
    end)

    on_install("@linux", function (package)

        if linuxos.name() == "ubuntu" and linuxos.version():eq("20.04") and os.arch() == "x86_64" then
            os.cp("*", package:installdir())
            return
        end

        local projects = {
            "clang",
            "clang-tools-extra",
            "lld",
            "lldb",
            "openmp",
            "polly",
            "mlir",
        }
        local projects_enabled = {}
        for _, project in ipairs(projects) do
            if package:config(project) then
                table.insert(projects_enabled, project)
            end
        end
        local runtimes = {
            "compiler-rt",
            "libunwind",
            "libcxxabi"
        }
        local runtimes_enabled = {}
        for _, runtime in ipairs(runtimes) do
            if package:config(runtime) then
                table.insert(runtimes_enabled, runtime)
            end
        end
        local configs = {
            "-DCMAKE_BUILD_TYPE=Release",
            "-DLLVM_ENABLE_PROJECTS=" .. table.concat(projects_enabled, ";"),
            "-DLLVM_ENABLE_RUNTIMES=" .. table.concat(runtimes_enabled, ";"),
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
        os.vrun("llvm-config --version")
        if package:config("clang") then
            os.vrun("clang --version")
        end
    end)
